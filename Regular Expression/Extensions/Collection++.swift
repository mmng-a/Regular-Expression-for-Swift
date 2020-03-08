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
            let index = self.index(startIndex, offsetBy: 2)
            let initialValue = Union(self[startIndex],
                                     self[self.index(startIndex, offsetBy: 1)])
            let node: Node = self[index...]
                .reduce(initialValue) { r, e in Union(r, e) }
            return node
        }
    }
}
