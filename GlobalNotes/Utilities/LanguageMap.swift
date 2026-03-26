import Foundation

/// Maps programming languages to their keywords for syntax highlighting.
enum LanguageMap {

    static let languages: [String] = [
        "Swift", "Python", "JavaScript", "TypeScript", "HTML", "CSS",
        "Java", "Kotlin", "Go", "Rust", "C", "C++", "Ruby", "PHP",
        "SQL", "Shell", "Dart", "R", "Scala", "Perl", "Lua", "YAML"
    ]

    static func keywords(for language: String) -> [String] {
        switch language.lowercased() {
        case "swift":
            return ["func", "var", "let", "if", "else", "for", "while", "return",
                    "import", "class", "struct", "enum", "protocol", "guard",
                    "switch", "case", "break", "continue", "self", "true", "false",
                    "nil", "throws", "async", "await", "try", "catch", "init",
                    "private", "public", "internal", "static", "final", "override"]
        case "python":
            return ["def", "class", "if", "elif", "else", "for", "while", "return",
                    "import", "from", "as", "try", "except", "finally", "with",
                    "lambda", "yield", "pass", "break", "continue", "True", "False",
                    "None", "and", "or", "not", "in", "is", "async", "await"]
        case "javascript", "typescript":
            return ["function", "const", "let", "var", "if", "else", "for", "while",
                    "return", "import", "export", "class", "new", "this", "super",
                    "switch", "case", "break", "continue", "true", "false", "null",
                    "undefined", "try", "catch", "finally", "async", "await", "throw",
                    "typeof", "instanceof", "default", "from"]
        case "java", "kotlin":
            return ["class", "public", "private", "protected", "static", "final",
                    "void", "int", "boolean", "if", "else", "for", "while", "return",
                    "new", "this", "super", "import", "package", "try", "catch",
                    "throw", "throws", "extends", "implements", "interface", "abstract",
                    "true", "false", "null", "switch", "case", "break", "continue",
                    "fun", "val", "var", "when", "object", "companion"]
        case "go":
            return ["func", "var", "const", "if", "else", "for", "return", "import",
                    "package", "type", "struct", "interface", "map", "chan", "go",
                    "defer", "switch", "case", "break", "continue", "range", "select",
                    "true", "false", "nil"]
        case "rust":
            return ["fn", "let", "mut", "if", "else", "for", "while", "loop",
                    "return", "use", "mod", "pub", "struct", "enum", "impl", "trait",
                    "match", "self", "super", "true", "false", "async", "await",
                    "move", "ref", "where", "type", "const", "static", "unsafe"]
        case "c", "c++":
            return ["int", "char", "float", "double", "void", "if", "else", "for",
                    "while", "return", "include", "define", "struct", "typedef",
                    "switch", "case", "break", "continue", "const", "static",
                    "class", "public", "private", "protected", "virtual", "template",
                    "namespace", "using", "new", "delete", "true", "false", "nullptr"]
        case "ruby":
            return ["def", "class", "module", "if", "elsif", "else", "unless",
                    "while", "until", "for", "do", "end", "return", "require",
                    "include", "attr_accessor", "yield", "begin", "rescue", "ensure",
                    "true", "false", "nil", "self", "super", "puts", "print"]
        case "php":
            return ["function", "class", "if", "else", "elseif", "for", "foreach",
                    "while", "return", "echo", "print", "public", "private",
                    "protected", "static", "new", "try", "catch", "throw",
                    "namespace", "use", "true", "false", "null", "array", "isset"]
        case "sql":
            return ["SELECT", "FROM", "WHERE", "INSERT", "UPDATE", "DELETE", "CREATE",
                    "TABLE", "DROP", "ALTER", "JOIN", "LEFT", "RIGHT", "INNER",
                    "OUTER", "ON", "AND", "OR", "NOT", "NULL", "ORDER", "BY",
                    "GROUP", "HAVING", "LIMIT", "DISTINCT", "AS", "IN", "SET",
                    "VALUES", "INTO", "INDEX", "PRIMARY", "KEY", "FOREIGN"]
        case "shell":
            return ["if", "then", "else", "elif", "fi", "for", "while", "do",
                    "done", "case", "esac", "function", "return", "echo", "exit",
                    "export", "source", "local", "readonly", "shift", "true", "false"]
        case "dart":
            return ["void", "var", "final", "const", "if", "else", "for", "while",
                    "return", "import", "class", "extends", "implements", "mixin",
                    "async", "await", "try", "catch", "throw", "new", "this",
                    "super", "true", "false", "null", "dynamic", "abstract"]
        default:
            return ["if", "else", "for", "while", "return", "function", "class",
                    "var", "let", "const", "true", "false", "null"]
        }
    }
}
