#include <iostream>
#include "renderer.cpp"

int main() {
    std::string html = "<html><body><h1>Hello, Nexus!</h1></body></html>";
    std::string css = "h1 { color: purple; }";

    HTMLParser htmlParser;
    CSSParser cssParser;
    Renderer renderer;

    HTMLElement root = htmlParser.parse(html);
    std::vector<CSSRule> cssRules = cssParser.parse(css);

    renderer.render(root, cssRules);

    return 0;
}
