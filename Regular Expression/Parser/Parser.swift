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
            throw ParseError.syntax
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
        var description: String {
            switch self {
            case .syntax: return "Syntax Error"
            }
        }
    }
}

extension Parser {
    
    // 規則F: `a`, `(ab|c*)`
    // 括弧で囲まれたsubExpressionかCHARACTER
    // factor -> (`(` subExpression `)`) | CHARACTER
    mutating func factor() throws -> Node {
        do {
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
                while self.look.kind != .rSquareBracket {
                    nodes.append(try star())
                }
                try self.match(tag: .rSquareBracket)
                
                // Optional<Character>.none, Character, Union<Node, Union<Node, ...>>
                node = nodes.makeNode()
            } else {
                // CHARACTER
                guard case .character(let c) = self.look else {
                    throw ParseError.syntax
                }
                node = c
                try self.match(tag: .character)
            }
            
            guard self.look == .lCurlyBracket else { return node }
            // {3}, {1, 3} など複数の場合 ↓
            try self.match(tag: .lCurlyBracket)
            let string = try self.sequence().toString()
            try self.match(tag: .rCurlyBracket)
            let strings = string.filter { $0 != " " }.split(separator: ",")
            
            func makeConcat(count: Int) -> Node {
                count == 1 ? node :
                    (2..<count).reduce(Concat(node, node)) { r, _ in Concat(node, r) }
            }
            
            if strings.count == 1 {         // {3}
                guard let count = Int(strings[0]), count >= 0 else { throw ParseError.syntax }
                // return Concat(node, Concat(node, Concat(node, ...)))
                return makeConcat(count: count)
            } else if strings.count == 2 {  // {1, 3}
                guard let start = Int(strings[0]), let end = Int(strings[1]),
                    0 <= start, start <= end else { throw ParseError.syntax }
                // Many times, return Union(Concat(), Union(Concat(), ...))
                return (start...end).map(makeConcat(count:)).makeNode()
            } else {
                throw ParseError.syntax
            }
        } catch {
            throw ParseError.syntax
        }
    }
    
    // 規則E: `a*`, `a`, `(ab)*`
    // factor、もしくはfactorに*をつけたもの
    // star -> (factor `*`) | factor
    mutating func star() throws -> Node {
        do {
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
        } catch {
            throw ParseError.syntax
        }
    }

    // 規則D: `ab`, `a*bc`, `(ab)*cd`
    // starを一個以上繋げたもの
    // sequence -> subSequence | ``
    mutating func sequence() throws -> Node {
        if [.lParen, .character, .lSquareBracket, .lCurlyBracket].contains(self.look.kind) {
            return try self.subSequence()
        } else {
            return Optional<Character>.none
        }
    }
    
    // 規則C: `(ab)*cd`, ``
    // 文字列か空文字
    // subSequence -> star (subSequence | star)
    mutating func subSequence() throws -> Node {
        do {
            let node = try self.star()
            // 元は[.lParen, .character]. 増やしていいか怪しいものを感じる. sequenceも.
            if [.lParen, .character, .lSquareBracket, .lCurlyBracket].contains(self.look.kind) {
                let node2 = try self.subSequence()
                return Concat(node, node2)
            } else {
                return node
            }
        } catch {
            throw ParseError.syntax
        }
    }
    
    // 規則B: `a|b`, `a*bc|(ab)*cd|`
    // sequenceを`|`で一個以上繋げたもの
    // subExpression -> (sequence `|` subExpression) | sequence
    mutating func subExpression() throws -> Node {
        do {
            var node = try self.sequence()
            if self.look == .union {
                try self.match(tag: .union)
                let node2 = try self.subExpression()
                node = Union(node, node2)
            }
            return node
        } catch {
            throw ParseError.syntax
        }
    }
    
    // 規則A: `a*bc|(ab)*cd|` + EOF
    // 末尾にEOFがある
    // expression -> subExpression + `EOF`
    mutating func expression() throws -> NondeterministicFiniteAutomaton {
        do {
            let node = try self.subExpression()
            try self.match(tag: .EOF)
            
            var context = Context()
            let fragment = node.assemble(&context)
//            print(fragment)
            return fragment.build()
        } catch {
            throw ParseError.syntax
        }
    }
}
