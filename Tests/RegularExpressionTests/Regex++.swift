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
            pattern: .init(wrappedValue: pattern),
            text:    .init(wrappedValue: nil, help: .init(), transform: {$0}),
            matchHeadAndTail: false
        )
    }
}
