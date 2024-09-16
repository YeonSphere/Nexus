use std::collections::HashSet;
use regex::Regex;
use url::Url;
use fnv::FnvHashSet;
use ahash::AHashMap;
use smallvec::SmallVec;
use rayon::prelude::*;
use reqwest;
use tokio;

pub struct AdBlocker {
    enabled: bool,
    network_filters: FnvHashSet<String>,
    cosmetic_filters: AHashMap<String, SmallVec<[Regex; 4]>>,
    whitelist: HashSet<String>,
    custom_filter_sources: Vec<String>,
}

impl AdBlocker {
    pub fn new() -> Self {
        AdBlocker {
            enabled: false,
            network_filters: FnvHashSet::default(),
            cosmetic_filters: AHashMap::new(),
            whitelist: HashSet::new(),
            custom_filter_sources: Vec::new(),
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
            std::fs::read_to_string(source)?
        };

        self.parse_filter_list(&content, source).await?;

        log::info!("Filter list loaded from source: {}", source);
        Ok(())
    }

    pub fn load_filter_lists(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        let sources = vec![
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts",
            "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt",
            "https://easylist.to/easylist/easylist.txt",
            "https://easylist.to/easylist/easyprivacy.txt",
            "local_filters.json"
        ];

        let runtime = tokio::runtime::Runtime::new()?;
        
        for source in sources {
            if let Err(e) = runtime.block_on(self.load_filter_lists_from_source(source)) {
                log::error!("Failed to load filter list from {}: {}", source, e);
            }
        }

        log::info!("All filter lists loaded");
        Ok(())
    }

    pub fn add_custom_filter_list(&mut self, source: String) {
        // TODO: Implement validation for the source
        self.custom_filter_sources.push(source);
    }

    pub async fn update_filter_lists(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        self.network_filters.clear();
        self.cosmetic_filters.clear();
        self.load_filter_lists()?;
        Ok(())
    }
}
