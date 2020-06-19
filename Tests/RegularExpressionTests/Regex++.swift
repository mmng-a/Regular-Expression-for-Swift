import ArgumentParser
@testable import RegularExpression

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
