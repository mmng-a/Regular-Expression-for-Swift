
enum Char: Equatable, Hashable {
    case character(_ character: Character)
    case null
    case any
    case range(_ range: ClosedRange<Character>)
}

extension Char {
    func contains(_ character: Char) -> Bool{
        switch (self, character) {
        case (let a, let b) where a == b:
            return true
        case (.character, _), (.null, _):
            return false
        case (_, .null):
            return false
        case (.any, _):
            return true
        case (.range(let range), .character(let char)):
            return range.contains(char)
        case (.range(let x), .range(let y)):
            return x.lowerBound <= y.lowerBound && y.upperBound <= x.upperBound
        case (.range, _):
            return false
        }
    }
}

extension Char: CustomStringConvertible {
    var description: String {
        switch self {
        case .character(let c): return c.description
        case .null: return ""
        case .any:  return "."
        case .range(let range): return "\(range.lowerBound)\(range.upperBound)"
        }
    }
}
