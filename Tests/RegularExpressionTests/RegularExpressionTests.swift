import XCTest
@testable import RegularExpression

typealias DFA = DeterministicFiniteAutomaton

final class RegularExpressionTests: XCTestCase {

    func testStar() throws {
        let dfa = try DFA.create(pattern: "a*")
        for input in ["", "a", "aaaaaa"] {
            var runtime = dfa.getRuntime()
            XCTAssertTrue(runtime.accept(input: input))
        }
        
        for input in [" ", "aabaaa", "failed"] {
            var runtime = dfa.getRuntime()
            XCTAssertFalse(runtime.accept(input: input))
        }
    }
    
    func testUnion() throws {
        let dfa = try DFA.create(pattern: "s(wift|mart|uper)")
        for input in ["swift", "smart", "super"] {
            var runtime = dfa.getRuntime()
            XCTAssertTrue(runtime.accept(input: input))
        }
        
        for input in ["", "rust", "Swift", "wift", "failed"] {
            var runtime = dfa.getRuntime()
            XCTAssertFalse(runtime.accept(input: input))
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            let dfa = try! DFA.create(pattern: "a{1,1000}")
            _ = dfa.getRuntime()
        }
    }
    
    static var allTests = [
        ("testStar",  testStar),
        ("testUnion", testUnion),
    ]

}
