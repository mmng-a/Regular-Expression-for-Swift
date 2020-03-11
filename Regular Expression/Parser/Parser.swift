//
//  Parser.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

struct Parser {
    var lexer: Lexer
    var look: Token!
    
    init(lexer: Lexer) {
        self.lexer = lexer
        self.look = nil
        self.move()
    }
    
    mutating func match(tag: Token.Kind) throws {
//        print(look!)
        if look.kind != tag {
            switch tag {
            case .character, .union, .star, .plus, .question,
                 .lParen, .lSquareBracket, .hyphen, .lCurlyBracket, .EOF:
                throw ParseError.syntax
            case .rParen:         throw ParseError.paren
            case .rSquareBracket: throw ParseError.squareBracket
            case .rCurlyBracket:  throw ParseError.curlyBracket
            }
        }
        self.move()
    }
    
    mutating func move() {
        self.look = self.lexer.scan()
    }
}

extension Parser {
    enum ParseError: Error, CustomStringConvertible {
        case syntax
        case curlyBracket
        case squareBracket
        case paren
        case number
        case other(String)
        
        var description: String {
            switch self {
            case .syntax:        return "Syntax Error"
            case .curlyBracket:  return "Missing `}`"
            case .squareBracket: return "Missing `]`"
            case .paren:         return "Missing `)`"
            case .number:        return "Expect number in `{}`"
            case .other(let s):  return s
            }
        }
    }
}

extension Parser {
    
    /// 規則F: `a`, `(ab|c*)`
    ///
    /// 括弧で囲まれたsubExpressionかCHARACTER
    /// factor -> (`(` subExpression `)`) | CHARACTER
    mutating func factor() throws -> Node {
        let node: Node
        if self.look == .lParen {
            // `(` subExpression `)`
            try self.match(tag: .lParen)
            node = try self.subExpression()
            try self.match(tag: .rParen)
        } else if self.look == .lSquareBracket {
            // [ CHARACTERs ]
            try self.match(tag: .lSquareBracket)
            // ココうまい方法ありそう
            var nodes = [Node]()
            while self.look.kind != .rSquareBracket && self.look.kind != .EOF {
                let node = try factor()
                guard self.look.kind == .hyphen else {
                    nodes.append(node)
                    continue
                }
                // [a-z]などの場合
                try self.match(tag: .hyphen)
                guard let start = node as? Character,
                    [.rSquareBracket, .EOF].contains(self.look.kind),
                    let node2 = try? factor() else {
                        // 普通に`-`をCHARACTERとして扱っている場合
                        nodes.append(node)
                        nodes.append(Character("-"))
                        continue
                }
                if let end = node2 as? Character {
                    let characters = [Character](from: start, to: end)
                    nodes.append(contentsOf: characters)
                } else {
                    nodes.append(node)
                    nodes.append(Token.hyphen.character!)
                    nodes.append(contentsOf: [Character](node2.toString()))
                }
            }
            try self.match(tag: .rSquareBracket)
            
            node = nodes.makeNode()
        } else if self.look == .hyphen {
            try self.match(tag: .hyphen)
            node = Character("-")
        } else {
            // CHARACTER
            guard case .character(let c) = self.look else { throw ParseError.syntax }
            try self.match(tag: .character)
            node = c
        }
        
        guard self.look == .lCurlyBracket else { return node }
        
        // {3}, {1, 3} など文字数指定のある場合 ↓
        try self.match(tag: .lCurlyBracket)
        let string = try self.sequence().toString()
        try self.match(tag: .rCurlyBracket)
        let strings = string.filter { $0 != " " }.split(separator: ",")
        
        func makeConcat(count: Int) -> Node {
            count == 1 ? node :
                (2..<count).reduce(Concat(node, node)) { r, _ in Concat(node, r) }
        }
        
        if strings.count == 1 {         // {3}
            guard let count = Int(strings[0]) else { throw ParseError.number }
            guard count >= 0 else { throw ParseError.other("{num} must be greater than 0") }
            // return Concat(node, Concat(node, Concat(node, ...)))
            return makeConcat(count: count)
        } else if strings.count == 2 {  // {1, 3}
            guard let start = Int(strings[0]), let end = Int(strings[1]) else {
                throw ParseError.number
            }
            guard 0 <= start, start <= end else {
                throw ParseError.other("{a,b} must be `0 <= a <= b`")
            }
            // Many times, return Union(Concat(), Union(Concat(), ...))
            return (start...end).map(makeConcat(count:)).makeNode()
        } else {
            throw ParseError.other("{} must be {num} or {start,end}")
        }
    }
    
    /// 規則E: `a*`, `a`, `(ab)*`
    ///
    /// factor、もしくはfactorに*をつけたもの
    /// star -> (factor `*`) | factor
    mutating func star() throws -> Node {
        var node = try self.factor()
        if self.look == .star {
            try self.match(tag: .star)
            node = Star(node)
        } else if self.look == .plus {
            // plus -> factor factor `*`
            try self.match(tag: .plus)
            node = Concat(node, Star(node))
        } else if self.look == .question {
            // question -> factor | ``
            try self.match(tag: .question)
            node = Union(node, Optional<Character>.none)
        }
        return node
    }
    
    /// 規則D: `ab`, `a*bc`, `(ab)*cd`
    ///
    /// starを一個以上繋げたもの
    /// sequence -> subSequence | ``
    mutating func sequence() throws -> Node {
        if [.lParen, .character, .lSquareBracket, .lCurlyBracket, .hyphen]
            .contains(self.look.kind) {
            return try self.subSequence()
        } else {
            return Optional<Character>.none
        }
    }
    
    /// 規則C: `(ab)*cd`, ``
    ///
    /// 文字列か空文字
    /// subSequence -> star (subSequence | star)
    mutating func subSequence() throws -> Node {
        let node = try self.star()
        if [.lParen, .character, .lSquareBracket, .lCurlyBracket, .hyphen]
            .contains(self.look.kind) {
            let node2 = try self.subSequence()
            return Concat(node, node2)
        } else {
            return node
        }
    }
    
    /// 規則B: `a|b`, `a*bc|(ab)*cd|`
    ///
    /// sequenceを`|`で一個以上繋げたもの
    /// subExpression -> (sequence `|` subExpression) | sequence
    mutating func subExpression() throws -> Node {
        var node = try self.sequence()
        if self.look == .union {
            try self.match(tag: .union)
            let node2 = try self.subExpression()
            node = Union(node, node2)
        }
        return node
    }
    
    /// 規則A: `a*bc|(ab)*cd|` + EOF
    /// 
    /// 末尾にEOFがある
    /// expression -> subExpression + `EOF`
    mutating func expression() throws -> NondeterministicFiniteAutomaton {
        let node = try self.subExpression()
//        print(node)
        try self.match(tag: .EOF)
        
        var context = Context()
        let fragment = node.assemble(&context)
//        print(fragment)
        return fragment.build()
    }
}
