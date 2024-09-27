use std::fs;
use std::path::Path;

pub struct HtmlTemplate;

impl HtmlTemplate {
    pub fn get_main_template() -> String {
        Self::read_template_file("main.html")
    }

    pub fn get_settings_template() -> String {
        Self::read_template_file("settings.html")
    }

    pub fn get_devtools_template() -> String {
        Self::read_template_file("devtools.html")
    }

    fn read_template_file(filename: &str) -> String {
        let template_path = Path::new("templates").join(filename);
        fs::read_to_string(template_path)
            .unwrap_or_else(|_| format!("Failed to read {} template", filename))
    }

    pub fn render_template(template: &str, context: &[(&str, &str)]) -> String {
        let mut rendered = template.to_string();
        for (key, value) in context {
            rendered = rendered.replace(&format!("{{{{ {} }}}}", key), value);
        }
        rendered
    }
}
