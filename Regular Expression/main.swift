//
//  main.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

import ArgumentParser

struct Regex: ParsableCommand {
    
    @Argument(help: "You can use many syntax of regular expression without `.`.")
    var pattern: String
    
    @Argument(help: "If you enter the text, you can just see the result.\nOr you can try regex many times.")
    var text: String?
    
}

extension Regex {
    
    func run() throws {
        // 前方一致、完全一致、後方一致を振り分ける
        var pattern = self.pattern
        var condition: DeterministicFiniteAutomaton.Condition = .part
        if let first = pattern.first, let last = pattern.last {
            switch (first, last) {
            case ("^", "$"):
                pattern = String(pattern.dropFirst().dropLast())
                condition = .all
            case ("^",   _):
                pattern = String(pattern.dropFirst())
                condition = .head
            case (_,   "$"):
                pattern = String(pattern.dropLast())
                condition = .tail
            default:
                condition = .part
            }
        }
        
        let lexer = Lexer(text: pattern)
        var parser = Parser(lexer: lexer)
        guard let NFA = try? parser.expression() else {
            throw Parser.ParseError.syntax
        }
        var DFA = DeterministicFiniteAutomaton(from: NFA)
        DFA.condition = condition
        
        func printMatch(text: String) {
            var runtime = DFA.getRuntime()
            print(runtime.accept(input: text) ? "-> matched" : "-> not matched")
        }
        
        switch text {
        case .some(let string):
            printMatch(text: string)
        case .none:
            print("Enter any texts")
            while true {
                guard let string = readLine() else { continue }
                printMatch(text: string)
            }
        }
    }
    
    /// For Test. This function is heavy.
    /// - Parameter text: The text
    func callAsFunction(_ text: String) -> Bool? {
        let lexer = Lexer(text: self.pattern)
        var parser = Parser(lexer: lexer)
        guard let NFA = try? parser.expression() else { return nil }
        let DFA = DeterministicFiniteAutomaton(from: NFA)
        var runtime = DFA.getRuntime()
        return runtime.accept(input: text)
    }
}

Regex.main()
