
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
//    print(currentState)
  }
  
  public var isAccepted: Bool {
    !DFA.accepts.intersection(currentState).isEmpty
  }
  
  public mutating func accept(input: String) -> Bool {
    if input.isEmpty { return isAccepted }
    for c in input {
      transit(character: c)
      if isAccepted && !DFA.condition.contains(.tail) { return true }
    }
    if isAccepted { return true }
    return DFA.condition.contains(.head) ? false
      : accept(input: String(input.dropFirst()))
  }
}
