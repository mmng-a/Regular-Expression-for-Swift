
typealias DFARuntime = DeterministicFiniteAutomaton.Runtime

extension DeterministicFiniteAutomaton {
    
    public struct Runtime {
        let DFA: DeterministicFiniteAutomaton
        var currentState: Set<Int>
    }
    
    public func getRuntime() -> Runtime {
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
    
    public var isAccepted: Bool {
        !DFA.accepts.intersection(currentState).isEmpty
    }
    
    public mutating func accept(input: String) -> Bool {
        var text = input
        
        let head = [.all, .head].contains(DFA.condition)
        let tail = [.all, .tail].contains(DFA.condition)
        
        while !text.isEmpty {
            for c in text {
                transit(character: c)
                if isAccepted && !tail { return true }
            }
            if head && input == text { return isAccepted }
            if isAccepted && !head { return true }
            currentState = DFA.start
            text.removeFirst()
        }
        return isAccepted
    }
}
