//
//  Regular_Expression_Test.swift
//  Regular Expression Test
//
//  Created by Masashi Aso on 2020/03/05.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

import XCTest
@testable import Regular_Expression

class Regular_Expression_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let regex = Regex(
            pattern: .init { _ in "[abc]?" },
            text:    .init { _ in nil }
        )
        XCTAssertTrue(regex.callAsFunction("a")!)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
