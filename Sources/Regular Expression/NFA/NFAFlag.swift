//
//  NFAFragment.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

extension NondeterministicFiniteAutomaton {
    
    struct Flag {
        var start: Int!
        var accepts: Set<Int> = []
        var dic: [Input: Set<Int>] = [:]
        
        struct Input: Hashable {
            var state: Int
            var character: Character?
            init(_ state: Int, _ character: Character?) {
                self.state = state
                self.character = character
            }
        }
        
        mutating func connect(from s1: Int, to s2: Int, with char: Character?) {
            self.dic[Input(s1, char), default: Set()].insert(s2)
        }
        
        func newSkelton() -> Flag {
            Flag(start: nil, accepts: [], dic: self.dic)
        }
        
        // `__or__`
        static func compose(_ x: Flag, _ y: Flag) -> Flag {
            var new = x.newSkelton()
            for (key, value) in y.dic {
                new.dic[key] = value
            }
            return new
        }
        
        func build() -> NondeterministicFiniteAutomaton {
            
            func transition(state: Int, character: Character?) -> Set<Int> {
                let input = Input(state, character)
                return dic[input, default: []]
            }
            
            return .init(transition: transition, start: start, accepts: accepts)
        }
    }
}

