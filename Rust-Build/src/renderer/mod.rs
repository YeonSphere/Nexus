pub mod html_parser;
pub mod css_parser;

pub use html_parser::HtmlParser;
pub use css_parser::CssParser;

pub struct Renderer {
    html_parser: HtmlParser,
    css_parser: CssParser,
}

impl Renderer {
    pub fn new() -> Self {
        Self {
            html_parser: HtmlParser,
            css_parser: CssParser,
        }
    }

    pub fn render(&self, html: &str, css: &str) -> Result<String, Box<dyn std::error::Error>> {
        let parsed_html = self.html_parser.parse(html)?;
        let parsed_css = self.css_parser.parse(css);

        Ok(format!("<!DOCTYPE html><html><head><style>{}</style></head><body>{}</body></html>", parsed_css, parsed_html))
    }
}
