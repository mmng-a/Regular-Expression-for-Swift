import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Regular_ExpressionTests.allTests),
    ]
}
#endif
