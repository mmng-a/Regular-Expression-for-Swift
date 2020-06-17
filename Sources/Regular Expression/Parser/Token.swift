
enum Token {
    case character(_ character: Character)
    case union, star, plus, question
    case lParen, rParen
    case lSquareBracket, rSquareBracket, hyphen
    case lCurlyBracket, rCurlyBracket
    case EOF
    
    var character: Character? {
        switch self {
        case .character(let c): return c
        case .union:            return "|"
        case .star:             return "*"
        case .plus:             return "+"
        case .question:         return "?"
        case .lParen:           return "("
        case .rParen:           return ")"
        case .lSquareBracket:   return "["
        case .rSquareBracket:   return "]"
        case .hyphen:           return "-"
        case .lCurlyBracket:    return "{"
        case .rCurlyBracket:    return "}"
        case .EOF:              return nil
        }
    }
}

extension Token: Hashable, Equatable {}

extension Token {
    func isSameKind(of other: Token) -> Bool {
        if case .character = self, case .character = other {
            return true
        } else {
            return self == other
        }
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        if case .character(let c) = self {
            return "Token(char: \(c))"
        } else {
            return "Token(\(character.flatMap(String.init) ?? "nil"))"
        }
    }
}
