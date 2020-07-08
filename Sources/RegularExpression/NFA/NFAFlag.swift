
typealias NFAFlag = NondeterministicFiniteAutomaton.Flag

extension NondeterministicFiniteAutomaton {
    struct Flag {
        var start: Int!
        var accepts: Set<Int> = []
        var dic: [Int: [Char: Set<Int>]] = [:]
    }
}


extension NFAFlag {
    
    mutating func connect(from s1: Int, to s2: Int, with char: Char) {
        self.dic[s1, default: [:]][char, default: []].insert(s2)
    }
    
    func createSkelton() -> NFAFlag {
        NFAFlag(start: nil, accepts: [], dic: self.dic)
    }
    
    static func compose(_ x: NFAFlag, _ y: NFAFlag) -> NFAFlag {
        var new = x.createSkelton()
        new.dic.merge(y.dic) { a, b in
            a.merging(b) { c, d in
                c.union(d)
            }
        }
        return new
    }
    
    func build() -> NondeterministicFiniteAutomaton {
        
        func transition(state: Int, character: Char) -> Set<Int> {
            let dictionary = dic[state, default: [:]]
            var result = Set<Int>()
            for (key, value) in dictionary where key.contains(character) {
                result.formUnion(value)
            }
            return result
        }
        
        return .init(transition: transition, start: start, accepts: accepts)
    }
}
