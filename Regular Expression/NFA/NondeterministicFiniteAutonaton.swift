//
//  NondeterministicFiniteAutonaton.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

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
//            print("expanding from \(set)... \(queue)\(done)")
            let stat = queue.popFirst()!
            let nexts = self.transition(stat, nil)
            done.insert(stat)
            
            for nextStat in nexts where !done.contains(nextStat) {
                queue.insert(nextStat)
            }
        }
        
        return done
    }
}
