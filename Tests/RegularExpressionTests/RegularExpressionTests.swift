import XCTest
@testable import RegularExpression

typealias DFA = DeterministicFiniteAutomaton

final class RegularExpressionTests: XCTestCase {
  
  func testStar() throws {
    let dfa = try DFA(pattern: "a*")
    for input in ["", "a", "aaaaaa"] {
      print(input)
      var runtime = dfa.getRuntime()
      for c in input {
        runtime.transit(character: c)
        print(runtime.currentState)
      }
      XCTAssertTrue(runtime.accept(input: input))
    }
    
    print("\n\n\n")
    
    for input in [" ", "aabaaa", "failed"] {
      print(input)
      var runtime = dfa.getRuntime()
      for c in input {
        runtime.transit(character: c)
        print(runtime.currentState)
      }
      XCTAssertFalse(runtime.accept(input: input))
    }
  }
  
  func testUnion() throws {
    let dfa = try DFA(pattern: "s(wift|mart|uper)")
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
      do {
        let dfa = try DFA(pattern: "a{1,1000}")
        _ = dfa.getRuntime()
      } catch {
        print(error)
      }
    }
  }
  
  static var allTests = [
    ("testStar",  testStar),
    ("testUnion", testUnion),
  ]
  
}
