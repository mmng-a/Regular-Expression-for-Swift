//
//  Parser.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

struct Parser {
    var lexer: Lexer
    var looking: Token!
    
    init(lexer: Lexer) {
        self.lexer = lexer
        self.looking = nil
        self.move()
    }
    
    mutating func matchKind(of tag: Token) throws {
        guard tag.isSameKind(of: self.looking) else {
            switch tag {
            case .character, .union, .star, .plus, .question,
                 .lParen, .lSquareBracket, .hyphen, .lCurlyBracket, .EOF:
                throw ParseError.syntax
            case .rParen:         throw ParseError.missing(.paren)
            case .rSquareBracket: throw ParseError.missing(.square)
            case .rCurlyBracket:  throw ParseError.missing(.curly)
            }
        }
        self.move()
    }
    
    mutating func move() {
        self.looking = self.lexer.scan()
    }
}

extension Parser {
    enum ParseError: Error, CustomStringConvertible {
        case syntax
        case missing(BracketType)
        case number
        case other(String)
        
        enum BracketType {
            case curly, square, paren
            var character: Character {
                switch self {
                case .curly:  return "}"
                case .square: return "]"
                case .paren:  return ")"
                }
            }
        }
        
        var description: String {
            switch self {
            case .syntax:         return "Syntax Error"
            case .missing(let b): return "Missing `\(b.character)`"
            case .number:         return "Expect number in `{}`"
            case .other(let s):   return s
            }
        }
    }
}

extension Parser {
    
    /// 規則F: `a`, `(ab|c*)`
    ///
    /// 括弧で囲まれたsubExpressionかCHARACTER
    ///
    /// `factor -> ( subExpression ) | CHARACTER`
    mutating func factor() throws -> Node {
        let node: Node
        switch self.looking {
        case .lParen:
            // `(` subExpression `)`
            try self.matchKind(of: .lParen)
            node = try self.subExpression()
            try self.matchKind(of: .rParen)
        case .lSquareBracket:
            // [ CHARACTERs ]
            try self.matchKind(of: .lSquareBracket)
            // ココうまい方法ありそう
            var nodes = [Node]()
            while self.looking != .rSquareBracket {
                let node = try factor()
                guard self.looking == .hyphen else {
                    nodes.append(node)
                    continue
                }
                // [a-z]などの場合
                try self.matchKind(of: .hyphen)
                if case let .character(start) = node,
                    let node2 = try? factor(),
                    self.looking == .rSquareBracket,
                    case let .character(end) = node2 {
                        let characters = [Character](from: start, to: end)
                        nodes.append(contentsOf: characters.map { Node.character($0) })
                } else {
                    nodes.append(node)
                    nodes.append(.character(Token.hyphen.character!))
                }
            }
            try self.matchKind(of: .rSquareBracket)
            
            node = Node.union(nodes)
        case .hyphen:
            try self.matchKind(of: .hyphen)
            node = .character(Token.hyphen.character!)
        default:
            // CHARACTER
            guard case .character(let char) = self.looking else { throw ParseError.syntax }
            try self.matchKind(of: .character(" "))
            node = .character(char)
        }
        
        // {3}, {1, 3} など文字数指定のある場合
        guard self.looking == .lCurlyBracket else { return node }
        try self.matchKind(of: .lCurlyBracket)
        let string = try self.sequence().string
        try self.matchKind(of: .rCurlyBracket)
        let strings = string.filter { $0 != " " }.split(separator: ",")
        
        switch strings.count {
        case 1:         // {3}
            guard let count = UInt(strings[0]) else { throw ParseError.number }
            return Node.repeat(node, ClosedRange(at: count))
        case 2:  // {1, 3}
            guard let start = UInt(strings[0]), let end = UInt(strings[1]) else {
                throw ParseError.number
            }
            guard 0 <= start, start <= end else {
                throw ParseError.other("{a,b} must be `0 <= a <= b`")
            }
            return Node.repeat(node, start...end)
        default:
            throw ParseError.other("{} must be {num} or {start,end}")
        }
    }
    
    /// 規則E: `a*`, `a`, `(ab)*`
    ///
    /// factor、もしくはfactorに*をつけたもの
    ///
    /// `star -> (factor *) | factor`
    mutating func star() throws -> Node {
        let node = try self.factor()
        switch self.looking {
        case .plus:
            try self.matchKind(of: .plus)
            return Node.plus(node)
        case .star:
            // plus -> factor factor `*`
            try self.matchKind(of: .star)
            return Node.star(node)
        case .question:
            // question -> factor | ``
            try self.matchKind(of: .question)
            return Node.union([node, .null])
        default:
            return node
        }
    }
    
    /// 規則D: `ab`, `a*bc`, `(ab)*cd`
    ///
    /// starを一個以上繋げたもの
    ///
    /// `sequence -> subSequence | null`
    mutating func sequence() throws -> Node {
        let tokens: [Token] = [.lParen, .character(" "), .lSquareBracket, .lCurlyBracket, .hyphen]
        if tokens.contains(where: { $0.isSameKind(of: self.looking) }) {
            return try self.subSequence()
        } else {
            return .null
        }
    }
    
    /// 規則C: `(ab)*cd`, ``
    ///
    /// 文字列か空文字
    ///
    /// `subSequence -> star (subSequence | star)`
    mutating func subSequence() throws -> Node {
        let node = try self.star()
        let tokens: [Token] = [.lParen, .character(" "), .lSquareBracket, .lCurlyBracket, .hyphen]
        if tokens.contains(where: { $0.isSameKind(of: self.looking) }) {
            let node2 = try self.subSequence()
            return Node.concat([node, node2])
        } else {
            return node
        }
    }
    
    /// 規則B: `a|b`, `a*bc|(ab)*cd|`
    ///
    /// sequenceを`|`で一個以上繋げたもの
    ///
    /// `subExpression -> (sequence | subExpression) | sequence`
    mutating func subExpression() throws -> Node {
        var node = try self.sequence()
        if self.looking == .union {
            try self.matchKind(of: .union)
            let node2 = try self.subExpression()
            node = .union([node, node2])
        }
        return node
    }
    
    /// 規則A: `a*bc|(ab)*cd|` + EOF
    /// 
    /// 末尾にEOFがある
    ///
    /// `expression -> subExpression + EOF`
    mutating func expression() throws -> NondeterministicFiniteAutomaton {
        let node = try self.subExpression()
//        print(node)
        try self.matchKind(of: .EOF)
        
        var context = Context()
        let fragment = node.assemble(&context)
//        print(fragment)
        return fragment.build()
    }
}
