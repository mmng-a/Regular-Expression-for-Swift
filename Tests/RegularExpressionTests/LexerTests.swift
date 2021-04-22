@testable import RegularExpression
import XCTest

class LexerTests: XCTestCase {
  
  func testScan() throws {
    var lexer = Lexer(text: "(a).[a(b]")
    
    let tokens1: [Token] = [
      .lParen,
      .character("a"),
      .rParen,
      .dot,
      .lSquareBracket,
    ]
    for token in tokens1 {
      XCTAssertEqual(lexer.scan(), token)
    }
    XCTAssertTrue(lexer.isInUnion)
    
    let tokens2: [Token] = [
      .character("a"),
      .character("("),
      .character("b"),
      .rSquareBracket,
    ]
    for token in tokens2 {
      XCTAssertEqual(lexer.scan(), token)
    }
  }
  
}
