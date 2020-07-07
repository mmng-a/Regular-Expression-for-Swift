
typealias NFAFlag = NondeterministicFiniteAutomaton.Flag

extension NondeterministicFiniteAutomaton {
    struct Flag {
        var start: Int!
        var accepts: Set<Int> = []
        var dic: [Input: Set<Int>] = [:]
    }
}


extension NFAFlag {
    
    // TODO: Tupleのauto conformanceでいらなくなる。
    struct Input: Hashable, CustomStringConvertible {
        var state: Int
        var character: Char
        init(_ state: Int, _ character: Char) {
            self.state = state
            self.character = character
        }
        var description: String {
            "NFAFlag.Input(start: \(state), character: \(character.description))"
        }
    }
    
    mutating func connect(from s1: Int, to s2: Int, with char: Char) {
        self.dic[Input(s1, char), default: Set()].insert(s2)
    }
    
    func createSkelton() -> NFAFlag {
        NFAFlag(start: nil, accepts: [], dic: self.dic)
    }
    
    static func compose(_ x: NFAFlag, _ y: NFAFlag) -> NFAFlag {
        var new = x.createSkelton()
        for (key, value) in y.dic {
            new.dic[key] = value
        }
        return new
    }
    
    func build() -> NondeterministicFiniteAutomaton {
        
        func transition(state: Int, character: Char) -> Set<Int> {
            let input = Input(state, character)
            return dic[input, default: []]
        }
        
        return .init(transition: transition, start: start, accepts: accepts)
    }
}
