#include <iostream>
#include <string>
#include <unordered_map>

class CSSRule {
public:
    std::string selector;
    std::unordered_map<std::string, std::string> properties;
};

class CSSParser {
public:
    std::vector<CSSRule> parse(const std::string& css) {
        std::vector<CSSRule> rules;
        // Add parsing logic here
        return rules;
    }
};
