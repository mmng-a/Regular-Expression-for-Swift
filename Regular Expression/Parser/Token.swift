//
//  Token.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

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

extension Token: Equatable {
    
    enum Kind {
        case character
        case union, star, plus, question
        case lParen, rParen
        case lSquareBracket, rSquareBracket, hyphen
        case lCurlyBracket, rCurlyBracket
        case EOF
    }
    
    var kind: Kind {
        switch self {
        case .character(_):   return .character
        case .union:          return .union
        case .star:           return .star
        case .plus:           return .plus
        case .question:       return .question
        case .lParen:         return .lParen
        case .rParen:         return .rParen
        case .lSquareBracket: return .lSquareBracket
        case .rSquareBracket: return .rSquareBracket
        case .hyphen:         return .hyphen
        case .lCurlyBracket:  return .lCurlyBracket
        case .rCurlyBracket:  return .rCurlyBracket
        case .EOF:            return .EOF
        }
    }
    
    static func ==(lhs: Token, rhs: Token) -> Bool {
        if case .character(let l) = lhs,
            case .character(let r) = rhs {
            return l == r
        }
        return lhs.kind == rhs.kind
    }
}
