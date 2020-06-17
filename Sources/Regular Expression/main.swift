
import ArgumentParser

struct Regex: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "Match a pattern against a text or texts.")
    
    @Argument(help: "You can use a lot of standard syntax of regular expression without `.`.")
    var pattern: String
    
    @Argument(help: "If you enter the text, you can just see the result. Or you can try regex many times.")
    var text: String?
    
    @Flag(help: "match '^' and '$'.")
    var matchHeadAndTail: Bool
}

extension Regex {
    
    func run() throws {
        var DFA = try createDFA()
        
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
        // 前方一致、完全一致、後方一致を振り分ける
        var pattern = self.pattern
        let condition: DeterministicFiniteAutomaton.Condition
        if matchHeadAndTail {
            condition =  getCondition(pattern: &pattern)
        } else {
            condition = .all
        }
        
        let lexer = Lexer(text: pattern)
        var parser = Parser(lexer: lexer)
        let NFA = try parser.expression()
        var DFA = DeterministicFiniteAutomaton(from: NFA)
        DFA.condition = condition
        return DFA
    }
    
    func getCondition(pattern: inout String) -> DeterministicFiniteAutomaton.Condition {
        switch (pattern.first, pattern.last) {
        case ("^", "$"):
            pattern.removeFirst()
            pattern.removeLast()
            return .all
        case ("^",  _ ):
            pattern.removeFirst()
            return .head
        case ( _ , "$"):
            pattern.removeLast()
            return .tail
        default:
            return .part
        }
    }
}

Regex.main()

