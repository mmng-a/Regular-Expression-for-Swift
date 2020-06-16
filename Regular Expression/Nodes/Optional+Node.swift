//
//  Optional+Node.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

// for empty character (epsilon)
extension Optional: NodeType where Wrapped: NodeType {
    
    func assemble(_ context: inout Context) -> NFAFlag {
        
        var frag = NFAFlag()
        let s1 = context.nextState()
        let s2 = context.nextState()
        frag.connect(from: s1, to: s2, with: self as? Character)
        
        frag.start = s1
        frag.accepts = [s2]
        
        return frag
    }
    
    func toString() -> String {
        switch self {
        case .some(let wrapped): return wrapped.toString()
        case .none: return ""
        }
    }
}
