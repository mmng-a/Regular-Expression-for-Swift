
struct NondeterministicFiniteAutomaton {
    
    var transition: (_ state: Int, _ character: Character?) -> Set<Int>
    var start: Int
    var accepts: Set<Int>
    
    init(transition: @escaping (_ state: Int, _ character: Character?) -> Set<Int>,
         start: Int, accepts: Set<Int>) {
        (self.transition, self.start, self.accepts) = (transition, start, accepts)
    }
}

extension NondeterministicFiniteAutomaton {
    
    func epsilonExpand(set: Set<Int>) -> Set<Int> {
        
        var queue: Set<Int> = set
        var done: Set<Int> = []
        
        while !queue.isEmpty {
            let stat = queue.popFirst()!
            let nexts = self.transition(stat, nil)
            done.insert(stat)
            
            for nextState in nexts where !done.contains(nextState) {
                queue.insert(nextState)
            }
        }
        
        return done
    }
}
