use wry::application::window::Window;

pub struct Theme {
    pub background_color: String,
    pub text_color: String,
    pub accent_color: String,
    pub secondary_accent_color: String,
}

impl Theme {
    pub fn dark() -> Self {
        Theme {
            background_color: "#1a1a2e".to_string(),
            text_color: "#e0e0e0".to_string(),
            accent_color: "#ff00ff".to_string(),
            secondary_accent_color: "#7b2cbf".to_string(),
        }
    }

    pub fn apply_to_window(&self, _window: &Window) {
        // Apply theme to window (if supported by wry)
        // This is a placeholder and may not be directly supported
    }

    pub fn get_css(&self) -> String {
        format!(
            r#"
            body {{
                font-family: Arial, sans-serif;
                background-color: {};
                color: {};
                margin: 0;
                padding: 20px;
            }}
            h1 {{
                color: {};
            }}
            input[type="text"] {{
                background-color: #16213e;
                color: {};
                border: 1px solid {};
                padding: 5px;
            }}
            button {{
                background-color: {};
                color: {};
                border: none;
                padding: 5px 10px;
                cursor: pointer;
            }}
            button:hover {{
                background-color: #9d4edd;
            }}
            "#,
            self.background_color,
            self.text_color,
            self.accent_color,
            self.text_color,
            self.accent_color,
            self.secondary_accent_color,
            self.text_color
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_dark_theme() {
        let theme = Theme::dark();
        assert_eq!(theme.background_color, "#1a1a2e");
        assert_eq!(theme.text_color, "#e0e0e0");
        assert_eq!(theme.accent_color, "#ff00ff");
        assert_eq!(theme.secondary_accent_color, "#7b2cbf");
    }
}
