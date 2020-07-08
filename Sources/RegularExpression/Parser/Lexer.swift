
struct Lexer {
    
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    mutating func scan() -> Token {
        if text.isEmpty { return Token.EOF }
        
        let c = text.removeFirst()
        
        switch c {
        case #"\"#:
            // not supporting `\p{UNICODE PROPERTY NAME}`
            let first = text.removeFirst()
            switch first {
            case "d":
                text.insert(contentsOf: "0-9]", at: text.startIndex)
                return Token.lSquareBracket
            case "s":
                text.insert(contentsOf: "\t\n\r \r\n]", at: text.startIndex)
                return Token.lSquareBracket
            case "w":
                text.insert(contentsOf: #"a-zA-Z0-9_]"#, at: text.startIndex)
                return Token.lSquareBracket
            default:
                return Token.character(first)
            }
        case ".": return Token.dot
        case "*": return Token.star
        case "+": return Token.plus
        case "|": return Token.union
        case "?": return Token.question
        case "(": return Token.lParen
        case ")": return Token.rParen
        case "[": return Token.lSquareBracket
        case "]": return Token.rSquareBracket
        case "-": return Token.hyphen
        case "{": return Token.lCurlyBracket
        case "}": return Token.rCurlyBracket
        default:  return Token.character(c)
        }
    }
}
