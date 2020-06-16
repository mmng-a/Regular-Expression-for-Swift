//
//  Context.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

struct Context {
    var stateCount = 0
    
    // `new_state`
    mutating func nextState() -> Int {
        self.stateCount += 1
        return stateCount
    }
}
