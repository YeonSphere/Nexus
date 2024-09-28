use wry::application::window::Window;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
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

    pub fn light() -> Self {
        Theme {
            background_color: "#f0f0f0".to_string(),
            text_color: "#333333".to_string(),
            accent_color: "#0066cc".to_string(),
            secondary_accent_color: "#4d94ff".to_string(),
        }
    }

    pub fn apply_to_window(&self, window: &Window) {
        // Apply theme to window (if supported by wry)
        // This is a placeholder and may not be directly supported
        // Consider using window.set_theme() if available in future wry versions
    }

    pub fn get_css(&self) -> String {
        format!(
            r#"
            :root {{
                --background-color: {};
                --text-color: {};
                --accent-color: {};
                --secondary-accent-color: {};
            }}
            body {{
                font-family: Arial, sans-serif;
                background-color: var(--background-color);
                color: var(--text-color);
                margin: 0;
                padding: 20px;
            }}
            h1, h2, h3 {{
                color: var(--accent-color);
            }}
            input[type="text"], input[type="search"] {{
                background-color: rgba(0, 0, 0, 0.1);
                color: var(--text-color);
                border: 1px solid var(--accent-color);
                padding: 8px;
                border-radius: 4px;
            }}
            button {{
                background-color: var(--secondary-accent-color);
                color: var(--text-color);
                border: none;
                padding: 8px 16px;
                cursor: pointer;
                transition: background-color 0.3s ease;
                border-radius: 4px;
            }}
            button:hover {{
                background-color: var(--accent-color);
            }}
            a {{
                color: var(--accent-color);
                text-decoration: none;
            }}
            a:hover {{
                text-decoration: underline;
            }}
            "#,
            self.background_color,
            self.text_color,
            self.accent_color,
            self.secondary_accent_color
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

    #[test]
    fn test_light_theme() {
        let theme = Theme::light();
        assert_eq!(theme.background_color, "#f0f0f0");
        assert_eq!(theme.text_color, "#333333");
        assert_eq!(theme.accent_color, "#0066cc");
        assert_eq!(theme.secondary_accent_color, "#4d94ff");
    }

    #[test]
    fn test_get_css() {
        let theme = Theme::dark();
        let css = theme.get_css();
        assert!(css.contains(&theme.background_color));
        assert!(css.contains(&theme.text_color));
        assert!(css.contains(&theme.accent_color));
        assert!(css.contains(&theme.secondary_accent_color));
    }
}
