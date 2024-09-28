use reqwest;
use serde_json::{json, Value};
use thiserror::Error;
use tokio;
use std::time::Duration;

#[derive(Error, Debug)]
pub enum AiEngineError {
    #[error("Request failed: {0}")]
    RequestFailed(#[from] reqwest::Error),
    #[error("Failed to parse AI response: {0}")]
    ParseError(String),
    #[error("Query processing timed out")]
    Timeout,
}

pub struct AiEngine {
    api_key: String,
    api_endpoint: String,
    model: String,
    max_tokens: u32,
    temperature: f32,
}

impl AiEngine {
    pub fn new(api_key: String) -> Self {
        AiEngine {
            api_key,
            api_endpoint: "https://api.openai.com/v1/chat/completions".to_string(),
            model: "gpt-3.5-turbo".to_string(),
            max_tokens: 150,
            temperature: 0.5,
        }
    }

    pub fn with_model(mut self, model: String) -> Self {
        self.model = model;
        self
    }

    pub fn with_max_tokens(mut self, max_tokens: u32) -> Self {
        self.max_tokens = max_tokens;
        self
    }

    pub fn with_temperature(mut self, temperature: f32) -> Self {
        self.temperature = temperature;
        self
    }

    pub async fn process_query(&self, query: &str) -> Result<String, AiEngineError> {
        let client = reqwest::Client::new();
        let response = client
            .post(&self.api_endpoint)
            .header("Authorization", format!("Bearer {}", self.api_key))
            .json(&json!({
                "model": self.model,
                "messages": [{"role": "user", "content": query}],
                "max_tokens": self.max_tokens,
                "n": 1,
                "temperature": self.temperature,
            }))
            .send()
            .await?;

        let response_json: Value = response.json().await?;
        let choices = response_json["choices"].as_array()
            .ok_or_else(|| AiEngineError::ParseError("Missing 'choices' array in AI response".to_string()))?;
        
        if choices.is_empty() {
            return Err(AiEngineError::ParseError("Empty 'choices' array in AI response".to_string()));
        }
        
        let message = choices[0]["message"].as_object()
            .ok_or_else(|| AiEngineError::ParseError("Missing 'message' object in AI response".to_string()))?;
        
        let ai_response = message.get("content")
            .and_then(|content| content.as_str())
            .ok_or_else(|| AiEngineError::ParseError("Missing or invalid 'content' field in AI response".to_string()))?
            .trim()
            .to_string();

        Ok(ai_response)
    }

    pub async fn process_query_with_timeout(&self, query: &str, timeout: Duration) -> Result<String, AiEngineError> {
        tokio::time::timeout(timeout, self.process_query(query))
            .await
            .map_err(|_| AiEngineError::Timeout)?
    }
}
