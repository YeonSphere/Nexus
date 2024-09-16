use std::collections::{HashSet, HashMap};
use regex::Regex;
use url::Url;
use fnv::FnvHashSet;
use ahash::AHashMap;
use smallvec::SmallVec;
use rayon::prelude::*;

pub struct AdBlocker {
    enabled: bool,
    network_filters: FnvHashSet<String>,
    cosmetic_filters: AHashMap<String, SmallVec<[Regex; 4]>>,
    whitelist: HashSet<String>,
}

impl AdBlocker {
    pub fn new() -> Self {
        AdBlocker {
            enabled: false,
            network_filters: FnvHashSet::default(),
            cosmetic_filters: AHashMap::new(),
            whitelist: HashSet::new(),
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

    pub fn add_cosmetic_filter(&mut self, domain: &str, filter: &str) {
        let regex = Regex::new(filter).unwrap();
        self.cosmetic_filters.entry(domain.to_string())
            .or_insert_with(SmallVec::new)
            .push(regex);
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

    pub fn load_filter_lists(&mut self) {
        // Implementation for loading filter lists from files or remote sources
        // This would involve reading from files or making HTTP requests
        // For demonstration purposes, we'll add some example filters
        self.add_network_filter("ads.example.com");
        self.add_network_filter("tracker.example.com");
        self.add_cosmetic_filter("example.com", r#"div[class*="ad-"]"#);
        self.add_cosmetic_filter("example.com", r#"iframe[src*="ads"]"#);
        self.add_whitelist("trusted-example.com");

        log::info!("Filter lists loaded");
    }
}
