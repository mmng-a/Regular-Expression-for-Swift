
struct NondeterministicFiniteAutomaton {
    
    var transition: (_ state: Int, _ character: Char) -> Set<Int>
    var start: Int
    var accepts: Set<Int>
    
    init(transition: @escaping (_ state: Int, _ character: Char) -> Set<Int>,
         start: Int, accepts: Set<Int>) {
        (self.transition, self.start, self.accepts) = (transition, start, accepts)
    }
}

extension NondeterministicFiniteAutomaton {
    
    func epsilonExpand(set: Set<Int>) -> Set<Int> {
        
        var queue: Set<Int> = set
        var done: Set<Int> = []
        
        while let state = queue.popFirst() {
            let nexts = self.transition(state, .null)
            done.insert(state)
            
            for nextState in nexts where !done.contains(nextState) {
                queue.insert(nextState)
            }
        }
        
        return done
    }
}
