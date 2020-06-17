
import XCTest
@testable import RegularExpression

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
