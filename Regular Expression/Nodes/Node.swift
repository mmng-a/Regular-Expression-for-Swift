//
//  Node2.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/06/16.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

enum Node {
    case character(Character?)
    indirect case `repeat`(Node, UInt?)
    case expression([Node])
    case union([Node])
}

