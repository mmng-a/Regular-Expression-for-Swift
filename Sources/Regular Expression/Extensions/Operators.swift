//
//  Operators.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/06/17.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

infix operator !!
func !!<T, E: Error>(lhs: Optional<T>, rhs: E) throws -> T {
    switch lhs {
    case .none:
        throw rhs
    case .some(let value):
        return value
    }
}
