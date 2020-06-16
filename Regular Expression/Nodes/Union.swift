//
//  Union.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

struct Union: NodeType {
    
    var nodes: [NodeType]
    
    init(_ nodes: [NodeType]) {
        self.nodes = nodes
    }
    
    func assemble(_ context: inout Context) -> NFAFlag {
        
        let frags = nodes.map { $0.assemble(&context) }
        var frag = frags[1...].reduce(frags[0]) {
            NFAFlag.compose($0, $1)
        }
        
        let state = context.nextState()
        frags.forEach {
            frag.connect(from: state, to: $0.start, with: nil)
        }
        
        frag.start = state
        frag.accepts = Set(frags.flatMap { $0.accepts })
        
        return frag
    }
    
    func toString() -> String {
        self.nodes.map { $0.toString() }.joined(separator: "|")
    }
}
