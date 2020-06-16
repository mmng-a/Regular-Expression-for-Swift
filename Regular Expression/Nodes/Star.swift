//
//  Star.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

struct Star: NodeType {
    
    var node: NodeType
    
    init(_ node: NodeType) {
        self.node = node
    }
    
    func assemble(_ context: inout Context) -> NFAFlag {
        
        let fragOriginal = node.assemble(&context)
        var frag = fragOriginal.newSkelton()
        
        for state in fragOriginal.accepts {
            frag.connect(from: state, to: fragOriginal.start, with: nil)
        }
        
        let state = context.nextState()
        frag.connect(from: state, to: fragOriginal.start, with: nil)
        
        frag.start = state
        frag.accepts = fragOriginal.accepts.union([state])
        return frag
    }
    
    func toString() -> String { node.toString() + "*" }
}
