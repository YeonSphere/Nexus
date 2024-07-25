#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>
#include <regex>

class CSSRule {
public:
    std::string selector;
    std::unordered_map<std::string, std::string> properties;
};

class CSSParser {
public:
    std::vector<CSSRule> parse(const std::string& css) {
        std::vector<CSSRule> rules;
        std::regex ruleRegex(R"(([^{}]+)\{([^{}]+)\})");
        std::regex propertyRegex(R"(([^:]+):([^;]+);)");

        auto rulesBegin = std::sregex_iterator(css.begin(), css.end(), ruleRegex);
        auto rulesEnd = std::sregex_iterator();

        for (std::sregex_iterator i = rulesBegin; i != rulesEnd; ++i) {
            std::smatch match = *i;
            CSSRule rule;
            rule.selector = trim(match.str(1));

            std::string properties = match.str(2);
            auto propertiesBegin = std::sregex_iterator(properties.begin(), properties.end(), propertyRegex);
            auto propertiesEnd = std::sregex_iterator();

            for (std::sregex_iterator j = propertiesBegin; j != propertiesEnd; ++j) {
                std::smatch propertyMatch = *j;
                std::string property = trim(propertyMatch.str(1));
                std::string value = trim(propertyMatch.str(2));
                rule.properties[property] = value;

                std::cout << "Property: " << property << ", Value: " << value << std::endl;
            }

            rules.push_back(rule);

            std::cout << "Selector: " << rule.selector << ", Properties: " << rule.properties.size() << std::endl;
        }

        return rules;
    }

private:
    std::string trim(const std::string& str) {
        size_t first = str.find_first_not_of(' ');
        if (first == std::string::npos) return "";
        size_t last = str.find_last_not_of(' ');
        return str.substr(first, last - first + 1);
    }
};
