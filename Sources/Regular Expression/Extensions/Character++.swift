//
//  Character++.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/06.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//


extension Character {
    
    init?(asciiCode: UInt32) {
        guard let scalar = UnicodeScalar(asciiCode) else {
            return nil
        }
        self = Character(scalar)
    }
    
    var asciiCode: UInt32 {
        let string = String(self)
        let scalars = string.unicodeScalars
        return scalars[scalars.startIndex].value
    }
    
}
