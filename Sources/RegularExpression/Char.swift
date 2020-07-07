
enum Char: Equatable, Hashable {
    case character(_ character: Character)
    case null
}

extension Char: CustomStringConvertible {
    var description: String {
        switch self {
        case .character(let c): return c.description
        case .null: return "null"
        }
    }
}
