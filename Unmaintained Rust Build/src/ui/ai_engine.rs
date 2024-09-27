use reqwest;
use serde_json::json;

pub struct AiEngine {
    api_key: String,
    api_endpoint: String,
}

impl AiEngine {
    pub fn new(api_key: String) -> Self {
        AiEngine {
            api_key,
            api_endpoint: "https://api.openai.com/v1/engines/davinci-codex/completions".to_string(),
        }
    }

    pub async fn process_query(&self, query: &str) -> Result<String, Box<dyn std::error::Error>> {
        let client = reqwest::Client::new();
        let response = client.post(&self.api_endpoint)
            .header("Authorization", format!("Bearer {}", self.api_key))
            .json(&json!({
                "prompt": query,
                "max_tokens": 150,
                "n": 1,
                "stop": null,
                "temperature": 0.5,
            }))
            .send()
            .await?;

        let response_json: serde_json::Value = response.json().await?;
        let ai_response = response_json["choices"][0]["text"].as_str()
            .ok_or("Failed to parse AI response")?
            .trim()
            .to_string();

        Ok(ai_response)
    }
}
