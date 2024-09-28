use std::collections::HashSet;
use regex::Regex;
use url::Url;
use fnv::FnvHashSet;
use ahash::AHashMap;
use smallvec::SmallVec;
use rayon::prelude::*;
use reqwest;
use tokio;
use serde_json;

pub struct AdBlocker {
    enabled: bool,
    network_filters: FnvHashSet<String>,
    cosmetic_filters: AHashMap<String, SmallVec<[Regex; 4]>>,
    whitelist: HashSet<String>,
    custom_filter_sources: Vec<String>,
    last_update: Option<chrono::DateTime<chrono::Utc>>,
}

impl AdBlocker {
    pub fn new() -> Self {
        AdBlocker {
            enabled: false,
            network_filters: FnvHashSet::default(),
            cosmetic_filters: AHashMap::new(),
            whitelist: HashSet::new(),
            custom_filter_sources: Vec::new(),
            last_update: None,
        }
    }

    pub fn set_enabled(&mut self, enabled: bool) {
        self.enabled = enabled;
    }

    pub fn is_enabled(&self) -> bool {
        self.enabled
    }

    pub fn add_network_filter(&mut self, filter: &str) {
        self.network_filters.insert(filter.to_string());
    }

    pub fn add_cosmetic_filter(&mut self, domain: &str, filter: &str) -> Result<(), regex::Error> {
        let regex = Regex::new(filter)?;
        self.cosmetic_filters.entry(domain.to_string())
            .or_insert_with(SmallVec::new)
            .push(regex);
        Ok(())
    }

    pub fn add_whitelist(&mut self, domain: &str) {
        self.whitelist.insert(domain.to_string());
    }

    pub fn should_block(&self, url: &str) -> bool {
        if !self.enabled {
            return false;
        }

        if let Ok(parsed_url) = Url::parse(url) {
            if let Some(domain) = parsed_url.domain() {
                if self.whitelist.contains(domain) {
                    return false;
                }
            }
        }

        self.network_filters.par_iter().any(|filter| url.contains(filter))
    }

    pub fn get_cosmetic_filters(&self, domain: &str) -> Vec<&Regex> {
        self.cosmetic_filters.get(domain)
            .map(|filters| filters.iter().collect())
            .unwrap_or_default()
    }

    async fn parse_filter_list(&mut self, content: &str, source: &str) -> Result<(), Box<dyn std::error::Error>> {
        for line in content.lines() {
            let line = line.trim();
            if line.is_empty() || line.starts_with('#') {
                continue;
            }

            if source.ends_with("hosts") {
                // Parse hosts file format
                let parts: Vec<&str> = line.split_whitespace().collect();
                if parts.len() >= 2 {
                    self.add_network_filter(parts[1]);
                }
            } else if source.ends_with(".txt") {
                // Parse AdBlock filter list format
                if line.contains("##") {
                    let parts: Vec<&str> = line.splitn(2, "##").collect();
                    if parts.len() == 2 {
                        self.add_cosmetic_filter(parts[0], parts[1])?;
                    }
                } else {
                    self.add_network_filter(line);
                }
            } else if source.ends_with(".json") {
                // Parse JSON format
                let json: serde_json::Value = serde_json::from_str(line)?;
                if let Some(filters) = json.as_object() {
                    for (domain, filter_list) in filters {
                        if let Some(filters) = filter_list.as_array() {
                            for filter in filters {
                                if let Some(filter_str) = filter.as_str() {
                                    self.add_cosmetic_filter(domain, filter_str)?;
                                }
                            }
                        }
                    }
                }
            } else {
                // Assume it's a network filter
                self.add_network_filter(line);
            }
        }

        Ok(())
    }

    pub async fn load_filter_lists_from_source(&mut self, source: &str) -> Result<(), Box<dyn std::error::Error>> {
        let content = if source.starts_with("http://") || source.starts_with("https://") {
            reqwest::get(source).await?.text().await?
        } else {
            tokio::fs::read_to_string(source).await?
        };

        self.parse_filter_list(&content, source).await?;

        log::info!("Filter list loaded from source: {}", source);
        Ok(())
    }

    pub async fn load_filter_lists(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        let sources = vec![
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts",
            "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt",
            "https://easylist.to/easylist/easylist.txt",
            "https://easylist.to/easylist/easyprivacy.txt",
            "local_filters.json"
        ];

        for source in sources {
            if let Err(e) = self.load_filter_lists_from_source(source).await {
                log::error!("Failed to load filter list from {}: {}", source, e);
            }
        }

        for source in &self.custom_filter_sources {
            if let Err(e) = self.load_filter_lists_from_source(source).await {
                log::error!("Failed to load custom filter list from {}: {}", source, e);
            }
        }

        self.last_update = Some(chrono::Utc::now());
        log::info!("All filter lists loaded");
        Ok(())
    }

    pub fn add_custom_filter_list(&mut self, source: String) {
        if Url::parse(&source).is_ok() || std::path::Path::new(&source).exists() {
            self.custom_filter_sources.push(source);
        } else {
            log::warn!("Invalid custom filter list source: {}", source);
        }
    }

    pub async fn update_filter_lists(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        self.network_filters.clear();
        self.cosmetic_filters.clear();
        self.load_filter_lists().await?;
        Ok(())
    }

    pub fn get_last_update(&self) -> Option<chrono::DateTime<chrono::Utc>> {
        self.last_update
    }

    pub async fn update_if_needed(&mut self, update_interval: chrono::Duration) -> Result<bool, Box<dyn std::error::Error>> {
        if let Some(last_update) = self.last_update {
            if chrono::Utc::now() - last_update > update_interval {
                self.update_filter_lists().await?;
                Ok(true)
            } else {
                Ok(false)
            }
        } else {
            self.update_filter_lists().await?;
            Ok(true)
        }
    }
}
