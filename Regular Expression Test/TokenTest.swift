//
//  TokenTest.swift
//  Regular Expression Test
//
//  Created by Masashi Aso on 2020/06/17.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

import XCTest
@testable import Regular_Expression

class TokenTest: XCTestCase {
    func test_isSameKind() {
        let a = Token.plus
        XCTAssertTrue(a.isSameKind(of: a))
        let b = Token.EOF
        XCTAssertTrue(b.isSameKind(of: b))
        let c = Token.character(" ")
        XCTAssertTrue(c.isSameKind(of: c))
    }
}
