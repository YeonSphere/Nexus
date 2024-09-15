use cssparser::{Parser, ParserInput};

pub struct CssParser;

impl CssParser {
    pub fn parse(&self, css: &str) -> String {
        let mut input = ParserInput::new(css);
        let mut parser = Parser::new(&mut input);
        let mut output = String::new();

        while let Ok(token) = parser.next() {
            match token {
                cssparser::Token::Ident(ident) => {
                    output.push_str(ident);
                    output.push(' ');
                }
                cssparser::Token::Function(func) => {
                    output.push_str(func);
                    output.push('(');
                }
                cssparser::Token::ParenthesisBlock => {
                    output.push(')');
                }
                cssparser::Token::CurlyBracketBlock => {
                    output.push_str(" {\n");
                    // Parse declarations inside the block
                    self.parse_declarations(&mut parser, &mut output);
                    output.push_str("}\n");
                }
                cssparser::Token::Colon => {
                    output.push(':');
                    output.push(' ');
                }
                cssparser::Token::Semicolon => {
                    output.push(';');
                    output.push('\n');
                }
                _ => {}
            }
        }

        output
    }

    fn parse_declarations<'i, 't>(
        &self,
        parser: &mut Parser<'i, 't>,
        output: &mut String,
    ) {
        while let Ok(token) = parser.next() {
            match token {
                cssparser::Token::Ident(ident) => {
                    output.push_str("  ");
                    output.push_str(ident);
                    output.push(':');
                    output.push(' ');
                }
                cssparser::Token::Colon => {
                    // Skip, we've already added it
                }
                cssparser::Token::Semicolon => {
                    output.push(';');
                    output.push('\n');
                }
                cssparser::Token::CloseCurlyBracket => {
                    break;
                }
                _ => {
                    // For simplicity, we'll just add the debug representation of other tokens
                    output.push_str(&format!("{:?}", token));
                    output.push(' ');
                }
            }
        }
    }
}
