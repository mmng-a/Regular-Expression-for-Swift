import ArgumentParser
import RegularExpression

struct Regex: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "Match a pattern against a text or texts.",
        discussion: "This RegEx command is using DFA engine, and pure Swift project.",
        version: "1.0"
    )
    
    @Argument(help: "You can use a lot of standard syntax of regular expression.")
    var pattern: String
    
    @Argument(help: "If you enter the text, you can just see the result. Or you can try regex many times.")
    var text: String?
    
    @Flag(help: "Match '^' and '$'.")
    var matchHeadAndTail = false
}

extension Regex {
    
    func run() throws {
        typealias DFA = DeterministicFiniteAutomaton
        let dfa = try DFA.create(pattern: pattern, matchesHeadAndTail: matchHeadAndTail)
        
        func printMatch(text: String) {
            var runtime = dfa.getRuntime()
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
}

Regex.main()
