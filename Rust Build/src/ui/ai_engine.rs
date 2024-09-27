use reqwest;
use serde_json::{json, Value};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AiEngineError {
    #[error("Request failed: {0}")]
    RequestFailed(#[from] reqwest::Error),
    #[error("Failed to parse AI response: {0}")]
    ParseError(String),
}

pub struct AiEngine {
    api_key: String,
    api_endpoint: String,
}

impl AiEngine {
    pub fn new(api_key: String) -> Self {
        AiEngine {
            api_key,
            api_endpoint: "https://api.openai.com/v1/chat/completions".to_string(),
        }
    }

    pub async fn process_query(&self, query: &str) -> Result<String, AiEngineError> {
        let client = reqwest::Client::new();
        let response = client
            .post(&self.api_endpoint)
            .header("Authorization", format!("Bearer {}", self.api_key))
            .json(&json!({
                "model": "gpt-3.5-turbo",
                "messages": [{"role": "user", "content": query}],
                "max_tokens": 150,
                "n": 1,
                "temperature": 0.5,
            }))
            .send()
            .await?;

        let response_json: Value = response.json().await?;
        let ai_response = response_json["choices"][0]["message"]["content"]
            .as_str()
            .ok_or_else(|| AiEngineError::ParseError("Failed to parse AI response".to_string()))?
            .trim()
            .to_string();

        Ok(ai_response)
    }
}
