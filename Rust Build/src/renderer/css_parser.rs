use cssparser::{Parser, ParserInput, Token};

pub struct CssParser;

impl CssParser {
    pub fn parse(&self, css: &str) -> String {
        let mut input = ParserInput::new(css);
        let mut parser = Parser::new(&mut input);
        let mut output = String::new();

        while let Ok(token) = parser.next() {
            match token {
                Token::Ident(ident) => {
                    output.push_str(ident);
                    output.push(' ');
                }
                Token::Function(func) => {
                    output.push_str(func);
                    output.push('(');
                }
                Token::ParenthesisBlock => {
                    output.push(')');
                }
                Token::CurlyBracketBlock => {
                    output.push_str(" {\n");
                    self.parse_declarations(&mut parser, &mut output);
                    output.push_str("}\n");
                }
                Token::Colon => {
                    output.push(':');
                    output.push(' ');
                }
                Token::Semicolon => {
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
                Token::Ident(ident) => {
                    output.push_str("  ");
                    output.push_str(ident);
                    output.push(':');
                    output.push(' ');
                }
                Token::Colon => {
                    // Skip, we've already added it
                }
                Token::Semicolon => {
                    output.push(';');
                    output.push('\n');
                }
                Token::CloseCurlyBracket => {
                    break;
                }
                _ => {
                    // For simplicity, we'll just add the string representation of other tokens
                    output.push_str(&token.to_string());
                    output.push(' ');
                }
            }
        }
    }
}
