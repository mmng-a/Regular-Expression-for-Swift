//
//  Collection++.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/03/05.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//


extension Collection where Element == Node {
    
    /// Make a node from `Collection<Node>`
    ///
    /// returns `Optional<Character>.none`, ` Character`, `Union<Node, Union<Node, ...>>`
    func makeNode() -> Node {
        if self.isEmpty {
            return Optional<Character>.none
        } else if self.count == 1 {
            return self[startIndex]
        } else {
            return Union(Array(self))
        }
    }
}
