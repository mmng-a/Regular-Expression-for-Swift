
typealias DFARuntime = DeterministicFiniteAutomaton.Runtime

extension DeterministicFiniteAutomaton {
    
    struct Runtime {
        let DFA: DeterministicFiniteAutomaton
        var currentState: Set<Int>
    }
    
    func getRuntime() -> Runtime {
        Runtime(DFA: self)
    }
}


extension DeterministicFiniteAutomaton.Runtime {
    
    init(DFA: DeterministicFiniteAutomaton) {
        self.DFA = DFA
        self.currentState = DFA.start
    }
    
    mutating func transit(character: Character) {
        currentState = DFA.transition(currentState, character)
//        print(currentState)
    }
    
    var isAcceptState: Bool {
        !DFA.accepts.intersection(currentState).isEmpty
//        DFA.accepts.contains(currentState)
    }
    
    mutating func accept(input: String) -> Bool {
        var text = input
        
        let head = [.all, .head].contains(DFA.condition)
        let tail = [.all, .tail].contains(DFA.condition)
        
        while !text.isEmpty {
            for c in text {
                transit(character: c)
                if isAcceptState && !tail { return true }
            }
            if head && input == text { return isAcceptState }
            if isAcceptState && !head { return true }
            currentState = DFA.start
            text = String(text.dropFirst())
        }
        return isAcceptState
    }
}
