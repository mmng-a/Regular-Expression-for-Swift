import XCTest
@testable import RegularExpression

typealias DFA = DeterministicFiniteAutomaton

final class RegularExpressionTests: XCTestCase {
  
  func testStar() throws {
    let dfa = try DFA(pattern: "a*", matchesHeadAndTail: false)
    var rs = Array(repeating: dfa.getRuntime(), count: 5)
    XCTAssertTrue (rs[0].accept(input: ""))
    XCTAssertTrue (rs[1].accept(input: "a"))
    XCTAssertTrue (rs[2].accept(input: "aaaaa"))
    XCTAssertFalse(rs[3].accept(input: "aaaba"))
    XCTAssertFalse(rs[4].accept(input: "bbbb"))
  }
  
  func testUnion() throws {
    let dfa = try DFA(pattern: "s(wift|mart|uper)")
    for input in ["swift", "smart", "super"] {
      var runtime = dfa.getRuntime()
      XCTAssertTrue(runtime.accept(input: input), input)
    }
    
    for input in ["", "rust", "Swift", "wift", "failed"] {
      var runtime = dfa.getRuntime()
      XCTAssertFalse(runtime.accept(input: input), input)
    }
  }
  
  func testNumberAt() throws {
    let dfa = try DFA(pattern: "a{3}")
    var rs = Array(repeating: dfa.getRuntime(), count: 4)
    XCTAssertFalse(rs[0].accept(input: ""))
    XCTAssertFalse(rs[1].accept(input: "aa"))
    XCTAssertTrue (rs[2].accept(input: "aaa"))
    XCTAssertFalse(rs[3].accept(input: "aaaa"))
  }
  
  func testNumberMax() throws {
    let dfa = try DFA(pattern: "a{,3}")
    var rs = Array(repeating: dfa.getRuntime(), count: 4)
    XCTAssertTrue (rs[0].accept(input: ""))
    XCTAssertTrue (rs[1].accept(input: "aa"))
    XCTAssertTrue (rs[2].accept(input: "aaa"))
    XCTAssertFalse(rs[3].accept(input: "aaaa"))
  }
  
  func testNumberMin() throws {
    let dfa = try DFA(pattern: "a{3,}")
    var rs = Array(repeating: dfa.getRuntime(), count: 4)
    XCTAssertFalse(rs[0].accept(input: ""))
    XCTAssertFalse(rs[1].accept(input: "aa"))
    XCTAssertTrue (rs[2].accept(input: "aaa"))
    XCTAssertTrue (rs[3].accept(input: "aaaa"))
  }
  
  func testNumber() throws {
    let dfa = try DFA(pattern: "a{3,5}")
    var rs = Array(repeating: dfa.getRuntime(), count: 7)
    XCTAssertFalse(rs[0].accept(input: ""))
    XCTAssertFalse(rs[1].accept(input: "aa"))
    XCTAssertTrue (rs[2].accept(input: "aaa"))
    XCTAssertTrue (rs[3].accept(input: "aaaa"))
    XCTAssertTrue (rs[4].accept(input: "aaaaa"))
    XCTAssertFalse(rs[5].accept(input: "aaaaaa"))
    XCTAssertFalse(rs[6].accept(input: "bbbb"))
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    let input = String(repeating: "a", count: 100)
    measure {
      do {
        let dfa = try DFA(pattern: "a{80,100}")
        var runtime = dfa.getRuntime()
        _ = runtime.accept(input: input)
      } catch {
        print(error)
      }
    }
  }
  
  static var allTests = [
    ("testStar",  testStar),
    ("testUnion", testUnion),
    ("testNumber", testNumber),
    ("testPerformanceExample", testPerformanceExample)
  ]
  
}
