import XCTest
@testable import RegularExpression

final class Regular_ExpressionTests: XCTestCase {

    func test_simpleStar() throws {
        let regex = Regex("[abc]?")
        XCTAssertTrue(try! regex("a"))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    static var allTests = [
        ("test_simpleStar", test_simpleStar)
    ]

}
