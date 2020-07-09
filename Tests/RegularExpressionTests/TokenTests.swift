import XCTest
@testable import RegularExpression

class TokenTest: XCTestCase {
    func test_isSameKind() {
        let a = Token.plus
        XCTAssertTrue(a.isSameKind(of: a))
        let b = Token.character("a")
        let c = Token.character(" ")
        XCTAssertTrue(b.isSameKind(of: c))
    }
}
