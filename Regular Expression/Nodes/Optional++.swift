//
//  Optional++.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

// for empty character (epsilon)
extension Optional: Node where Wrapped: Node {
    
    func assemble(_ context: inout Context) -> NFAFragment {
        
        var frag = NFAFragment()
        let s1 = context.nextState()
        let s2 = context.nextState()
        frag.connect(from: s1, to: s2, with: nil)
        
        frag.start = s1
        frag.accepts = [s2]
        
        return frag
    }
    
    func toString() -> String { "" }
}
