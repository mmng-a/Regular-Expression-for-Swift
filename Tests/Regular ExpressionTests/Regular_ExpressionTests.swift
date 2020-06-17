import XCTest
import ArgumentParser
@testable import Regular_Expression

extension Regex {
    /// For Test. This function is heavy.
    /// - Parameter text: The text
    func callAsFunction(_ text: String) throws -> Bool {
        let DFA = try createDFA()
        var runtime = DFA.getRuntime()
        return runtime.accept(input: text)
    }
    
    init(_ pattern: String) {
        self.init(
            pattern: Argument<String>(default: pattern, help: ""),
            text:    Argument<String?>(help: ""),
            matchHeadAndTail: Flag<Bool>()
        )
    }
}

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

}
