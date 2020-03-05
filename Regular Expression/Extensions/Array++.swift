//
//  Array++.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/06.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//


extension Array where Element == Character {
    
    init(from character1: Character, to character2: Character) {
        let a = character1.asciiCode
        let b = character2.asciiCode
        self = (a...b).map { Character(asciiCode: $0) }.compactMap { $0 }
    }
}
