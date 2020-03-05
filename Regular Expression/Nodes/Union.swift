//
//  Union.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

struct Union: Node {
    
    var node1, node2: Node
    
    init(_ node1: Node, _ node2: Node) {
        self.node1 = node1
        self.node2 = node2
    }
    
    func assemble(_ context: inout Context) -> NFAFragment {
        
        let frag1 = self.node1.assemble(&context)
        let frag2 = self.node2.assemble(&context)
        var frag = NFAFragment.compose(frag1, frag2)
        
        let state = context.nextState()
        frag.connect(from: state, to: frag1.start, with: nil)
        frag.connect(from: state, to: frag2.start, with: nil)
        
        frag.start = state
        frag.accepts = frag1.accepts.union(frag2.accepts)
        
        return frag
    }
    
    func toString() -> String { "\(node1.toString())|\(node2.toString())" }
}


extension Union {
    
    static let numbers = "1234567890".makeNode() as! Union
    
    static let alphabets = "abcdefghijklmnopqrstuvwxyz".makeNode() as! Union
}
