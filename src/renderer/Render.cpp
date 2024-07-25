#include <iostream>
#include <string>
#include <vector>
#include <unordered_map>
#include "html_parser.cpp"
#include "css_parser.cpp"

class Renderer {
public:
    void render(HTMLElement& root, const std::vector<CSSRule>& cssRules) {
        applyStyles(root, cssRules);
        renderElement(root);
    }

private:
    void applyStyles(HTMLElement& element, const std::vector<CSSRule>& cssRules) {
        for (const auto& rule : cssRules) {
            if (element.tag == rule.selector) {
                for (const auto& property : rule.properties) {
                    element.styles[property.first] = property.second;
                }
            }
        }

        for (auto& child : element.children) {
            applyStyles(child, cssRules);
        }
    }

    void renderElement(const HTMLElement& element) {
        std::cout << "<" << element.tag;
        for (const auto& attr : element.attributes) {
            std::cout << " " << attr.first << "=\"" << attr.second << "\"";
        }
        std::cout << ">";

        if (element.tag != "text") {
            for (const auto& child : element.children) {
                renderElement(child);
            }
            std::cout << "</" << element.tag << ">";
        } else {
            std::cout << element.textContent;
        }
    }
};
