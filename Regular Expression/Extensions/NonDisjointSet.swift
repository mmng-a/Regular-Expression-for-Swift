//
//  NonDisjointSet.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/04.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//


struct NonDisjointSet<Element> where Element: Hashable {
    
    let base: Set<Element>
    
    init(base: Set<Element>) {
        self.base = base
    }
    
    func contains(_ set: Set<Element>) -> Bool {
        (base.intersection(set)) == set && !set.isEmpty
    }
}
