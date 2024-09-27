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
        let choices = response_json["choices"].as_array().ok_or_else(|| AiEngineError::ParseError("Missing 'choices' array in AI response".to_string()))?;
        if choices.is_empty() {
            return Err(AiEngineError::ParseError("Empty 'choices' array in AI response".to_string()));
        }
        let message = choices[0]["message"].as_object().ok_or_else(|| AiEngineError::ParseError("Missing 'message' object in AI response".to_string()))?;
        let ai_response = message.get("content")
            .and_then(|content| content.as_str())
            .ok_or_else(|| AiEngineError::ParseError("Missing or invalid 'content' field in AI response".to_string()))?
            .trim()
            .to_string();

        Ok(ai_response)
    }
}
