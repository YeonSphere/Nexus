#include <iostream>
#include <string>
#include <vector>
#include <regex>

class HTMLElement {
public:
    std::string tag;
    std::vector<HTMLElement> children;
    std::unordered_map<std::string, std::string> attributes;

    std::string toString() const {
        std::string result = "<" + tag;
        for (const auto& attr : attributes) {
            result += " " + attr.first + "=\"" + attr.second + "\"";
        }
        result += ">";
        for (const auto& child : children) {
            result += child.toString();
        }
        result += "</" + tag + ">";
        return result;
    }
};

class HTMLParser {
public:
    HTMLElement parse(const std::string& html) {
        HTMLElement root;
        root.tag = "html";
        // Add parsing logic here
        return root;
    }

private:
    std::vector<std::string> tokenize(const std::string& html) {
        std::vector<std::string> tokens;
        std::regex tokenRegex(R"(<[^>]+>|[^<]+)");
        auto tokensBegin = std::sregex_iterator(html.begin(), html.end(), tokenRegex);
        auto tokensEnd = std::sregex_iterator();

        for (std::sregex_iterator i = tokensBegin; i != tokensEnd; ++i) {
            tokens.push_back(i->str());
        }

        return tokens;
    }

    HTMLElement parseElement(const std::vector<std::string>& tokens, size_t& index) {
        HTMLElement element;
        std::regex tagRegex(R"(<(\w+)([^>]*)>)");
        std::smatch match;

        if (std::regex_match(tokens[index], match, tagRegex)) {
            element.tag = match[1];
            std::string attributes = match[2];
            parseAttributes(attributes, element.attributes);
            ++index;

            while (index < tokens.size() && tokens[index] != "</" + element.tag + ">") {
                if (tokens[index][0] == '<') {
                    element.children.push_back(parseElement(tokens, index));
                } else {
                    HTMLElement textNode;
                    textNode.tag = "text";
                    textNode.children.push_back({tokens[index]});
                    element.children.push_back(textNode);
                    ++index;
                }
            }
            ++index; // Skip the closing tag
        }

        return element;
    }

    void parseAttributes(const std::string& attributes, std::unordered_map<std::string, std::string>& attrMap) {
        std::regex attrRegex(R"((\w+)="([^"]*)")");
        auto attrsBegin = std::sregex_iterator(attributes.begin(), attributes.end(), attrRegex);
        auto attrsEnd = std::sregex_iterator();

        for (std::sregex_iterator i = attrsBegin; i != attrsEnd; ++i) {
            std::smatch match = *i;
            attrMap[match[1]] = match[2];
        }
    }
};
