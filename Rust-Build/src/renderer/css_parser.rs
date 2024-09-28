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
                Token::AtKeyword(keyword) => {
                    output.push('@');
                    output.push_str(keyword);
                    output.push(' ');
                }
                Token::Hash(hash) => {
                    output.push('#');
                    output.push_str(hash);
                    output.push(' ');
                }
                Token::QuotedString(string) => {
                    output.push('"');
                    output.push_str(string);
                    output.push('"');
                    output.push(' ');
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
                Token::Number { value, .. } => {
                    output.push_str(&value.to_string());
                    output.push(' ');
                }
                Token::Dimension { value, unit, .. } => {
                    output.push_str(&value.to_string());
                    output.push_str(unit);
                    output.push(' ');
                }
                Token::Percentage { unit_value, .. } => {
                    output.push_str(&unit_value.to_string());
                    output.push('%');
                    output.push(' ');
                }
                _ => {
                    // For other tokens, we'll just add the string representation
                    output.push_str(&token.to_string());
                    output.push(' ');
                }
            }
        }
    }
}
