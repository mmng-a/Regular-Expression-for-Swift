import ArgumentParser

struct Regex: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "Match a pattern against a text or texts.")
    
    @Argument(help: "You can use a lot of standard syntax of regular expression.")
    var pattern: String
    
    @Argument(help: "If you enter the text, you can just see the result. Or you can try regex many times.")
    var text: String?
    
    @Flag(help: "Match '^' and '$'.")
    var matchHeadAndTail = false
}

extension Regex {
    
    func run() throws {
        let DFA = try createDFA()
        
        func printMatch(text: String) {
            var runtime = DFA.getRuntime()
            print(runtime.accept(input: text) ? "-> matched" : "-> not matched")
        }
        
        switch text {
        case .some(let string):
            printMatch(text: string)
        case .none:
            print("[Enter any texts]")
            while let string = readLine() {
                printMatch(text: string)
            }
        }
    }
    
    func createDFA() throws -> DeterministicFiniteAutomaton {
        typealias DFACondition = DeterministicFiniteAutomaton.Condition
        var pattern = self.pattern
        let condition = matchHeadAndTail ? DFACondition(from: &pattern) : .all
        
        let lexer = Lexer(text: pattern)
        var parser = Parser(lexer: lexer)
        let NFA = try parser.expression()
        var DFA = DeterministicFiniteAutomaton(from: NFA)
        DFA.condition = condition
        return DFA
    }
}

Regex.main()
