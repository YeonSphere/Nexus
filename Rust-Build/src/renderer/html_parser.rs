use html5ever::parse_document;
use html5ever::tendril::TendrilSink;
use markup5ever_rcdom::{Handle, NodeData, RcDom};
use std::borrow::Borrow;

pub struct HtmlParser;

impl HtmlParser {
    pub fn parse(&self, html: &str) -> Result<String, Box<dyn std::error::Error>> {
        let dom = parse_document(RcDom::default(), Default::default())
            .from_utf8()
            .read_from(&mut html.as_bytes())?;

        let mut output = String::new();
        self.serialize_node(&dom.document, &mut output, 0);
        Ok(output)
    }

    fn serialize_node(&self, handle: &Handle, output: &mut String, depth: usize) {
        let node = handle.borrow();
        match node.data {
            NodeData::Element { ref name, ref attrs, .. } => {
                output.push_str(&"  ".repeat(depth));
                output.push('<');
                output.push_str(&name.local);
                for attr in attrs.borrow().iter() {
                    output.push(' ');
                    output.push_str(&attr.name.local);
                    output.push_str("=\"");
                    output.push_str(&attr.value);
                    output.push('"');
                }
                output.push('>');
                output.push('\n');

                for child in node.children.borrow().iter() {
                    self.serialize_node(child, output, depth + 1);
                }

                output.push_str(&"  ".repeat(depth));
                output.push_str("</");
                output.push_str(&name.local);
                output.push_str(">\n");
            }
            NodeData::Text { ref contents } => {
                let text = contents.borrow().trim();
                if !text.is_empty() {
                    output.push_str(&"  ".repeat(depth));
                    output.push_str(text);
                    output.push('\n');
                }
            }
            NodeData::Comment { ref contents } => {
                output.push_str(&"  ".repeat(depth));
                output.push_str("<!--");
                output.push_str(contents);
                output.push_str("-->\n");
            }
            NodeData::Doctype { ref name, ref public_id, ref system_id } => {
                output.push_str("<!DOCTYPE ");
                output.push_str(name);
                if !public_id.is_empty() {
                    output.push_str(" PUBLIC \"");
                    output.push_str(public_id);
                    output.push('"');
                }
                if !system_id.is_empty() {
                    output.push_str(" \"");
                    output.push_str(system_id);
                    output.push('"');
                }
                output.push_str(">\n");
            }
            _ => {}
        }
    }
}
