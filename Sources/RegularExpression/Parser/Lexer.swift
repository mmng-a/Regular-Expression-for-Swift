
struct Lexer {
    
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    var isInUnion = false
    
    mutating func scan() -> Token {
        if text.isEmpty { return Token.EOF }
        
        if isInUnion {
            return scanUnion()
        } else {
            return _scan()
        }
    }
    
    private mutating func _scan() -> Token {
        let c = text.removeFirst()
        
        switch c {
        case "[":
            self.isInUnion = true
            return .lSquareBracket
        case #"\"#:
            // not supporting `\p{UNICODE PROPERTY NAME}`
            if text.isEmpty { return .EOF }
            let first = text.removeFirst()
            return .character(first)
        case ".": return .dot
        case "*": return .star
        case "+": return .plus
        case "|": return .union
        case "?": return .question
        case "(": return .lParen
        case ")": return .rParen
        case "{": return .lCurlyBracket
        case "}": return .rCurlyBracket
        default:  return .character(c)
        }
    }
    
    private mutating func scanUnion() -> Token {
        let c = text.removeFirst()
        
        switch c {
        case "]":
            self.isInUnion = false
            return .rSquareBracket
        case #"\"#:
            if text.isEmpty { return .EOF }
            let first = text.removeFirst()
            switch first {
            case "d":
                text.insert(contentsOf: "-9", at: text.startIndex)
                return .character("0")
            case "s":
                text.insert(contentsOf: "\t\n\r ", at: text.startIndex)
                return .character("\r\n")
            case "w":
                text.insert(contentsOf: "-zA-Z0-9_", at: text.startIndex)
                return .character("a")
            default:
                return .character(first)
            }
        case "-": return .hyphen
        default:  return .character(c)
        }
    }
}
