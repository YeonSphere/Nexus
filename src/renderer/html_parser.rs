use html5ever::parse_document;
use markup5ever_rcdom::{Handle, NodeData, RcDom};

pub struct HtmlParser;

impl HtmlParser {
    pub fn parse(&self, html: &str) -> String {
        let dom = parse_document(RcDom::default(), Default::default())
            .from_utf8()
            .read_from(&mut html.as_bytes())
            .unwrap();

        let mut output = String::new();
        self.serialize_node(&dom.document, &mut output, 0);
        output
    }

    fn serialize_node(&self, handle: &Handle, output: &mut String, depth: usize) {
        let node = handle.as_ref();
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
            }
            NodeData::Text { ref contents } => {
                output.push_str(&"  ".repeat(depth + 1));
                output.push_str(&contents.borrow());
                output.push('\n');
            }
            _ => {}
        }

        for child in node.children.iter() {
            self.serialize_node(child, output, depth + 1);
        }

        if let NodeData::Element { ref name, .. } = node.data {
            output.push_str(&"  ".repeat(depth));
            output.push_str("</");
            output.push_str(&name.local);
            output.push_str(">\n");
        }
    }
}
