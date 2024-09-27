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
        Renderer {
            html_parser: HtmlParser,
            css_parser: CssParser,
        }
    }

    pub fn render(&self, html: &str, css: &str) -> String {
        let parsed_html = self.html_parser.parse(html);
        let parsed_css = self.css_parser.parse(css);

        format!("<style>{}</style>{}", parsed_css, parsed_html)
    }
}
