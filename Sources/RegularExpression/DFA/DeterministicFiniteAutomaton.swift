
public struct DeterministicFiniteAutomaton {
  internal var transition: (_ state: Set<Int>, _ character: Character) -> Set<Int>
  private(set) var start: Set<Int>
  private(set) var accepts: Set<Int>
  
  init(
    transition: @escaping (_ state: Set<Int>, _ character: Character) -> Set<Int>,
    start: Set<Int>,
    accepts: Set<Int>
  ) {
    (self.transition, self.start, self.accepts) = (transition, start, accepts)
  }
  
  var condition: Condition = .all
  struct Condition: OptionSet {
    let rawValue: Int8
    static let head = Condition(rawValue: 1<<0)
    static let tail = Condition(rawValue: 1<<1)
    
    static let part: Condition = []
    static let all:  Condition = [.head, .tail]
  }
}

extension DeterministicFiniteAutomaton {
  
  init(from NFA: NondeterministicFiniteAutomaton) {
    
    func transition(set: Set<Int>, alpha: Character) -> Set<Int> {
      let ret: Set<Int> = set
        .map { element in
          NFA.transition(element, .character(alpha))
        }
        .reduce(into: Set<Int>()) { result, set in
          result.formUnion(set)
        }
      return NFA.epsilonExpand(set: ret)
    }
    
    self = .init(
      transition: transition(set:alpha:),
      start: NFA.epsilonExpand(set: [NFA.start]),
      accepts: NFA.epsilonExpand(set: NFA.accepts)
    )
  }
}

extension DeterministicFiniteAutomaton.Condition {
  init(from pattern: inout String) {
    switch (pattern.first, pattern.last) {
    case ("^", "$"):
      pattern.removeFirst()
      pattern.removeLast()
      self = .all
    case ("^",  _ ):
      pattern.removeFirst()
      self = .head
    case ( _ , "$"):
      pattern.removeLast()
      self = .tail
    case ( _ ,  _ ):
      self = .part
    }
  }
}

extension DeterministicFiniteAutomaton {
  public init(pattern: String, matchesHeadAndTail: Bool = false) throws {
    var pattern = pattern
    
    let lexer = Lexer(text: pattern)
    var parser = Parser(lexer: lexer)
    let NFA = try parser.expression()
    self = DeterministicFiniteAutomaton(from: NFA)
    self.condition = matchesHeadAndTail ? Condition(from: &pattern) : .all
  }
}
