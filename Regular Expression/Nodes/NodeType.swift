//
//  Node.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

protocol NodeType {
    
    typealias NFAFlag = NondeterministicFiniteAutomaton.Flag
    
    func assemble(_ context: inout Context) -> NFAFlag
    
    func toString() -> String
}
