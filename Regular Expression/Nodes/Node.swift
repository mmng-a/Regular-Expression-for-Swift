//
//  Node.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

protocol Node {
    
    typealias NFAFragment = NondeterministicFiniteAutomaton.Fragment
    
    func assemble(_ context: inout Context) -> NFAFragment
    
    func toString() -> String
}


