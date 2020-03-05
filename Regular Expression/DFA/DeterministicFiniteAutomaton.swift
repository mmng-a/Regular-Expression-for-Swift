//
//  DeterministicFiniteAutomaton.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

struct DeterministicFiniteAutomaton {
    var transition: (_ state: Set<Int>, _ character: Character) -> Set<Int>
    var start: Set<Int>
    var accepts: NonDisjointSet<Int>
    
    init(transition: @escaping (_ state: Set<Int>, _ character: Character) -> Set<Int>,
         start: Set<Int>, accepts: NonDisjointSet<Int>) {
        (self.transition, self.start, self.accepts) = (transition, start, accepts)
    }
}

extension DeterministicFiniteAutomaton {
    
    init(from NFA: NondeterministicFiniteAutomaton) {
        
        func transition(set: Set<Int>, alpha: Character) -> Set<Int> {
            let ret: Set<Int> = set.map { element in
                NFA.transition(element, alpha)
            }.reduce(into: Set<Int>()) { result, set in
                result.formUnion(set)
            }
            return NFA.epsilonExpand(set: ret)
        }
        
        self = .init(
            transition: transition(set:alpha:),
            start: NFA.epsilonExpand(set: [NFA.start]),
            accepts: NonDisjointSet(base: NFA.epsilonExpand(set: NFA.accepts))
        )
    }
    
}
