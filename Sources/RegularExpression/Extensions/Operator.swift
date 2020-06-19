
infix operator !!
func !!<T, E: Error>(lhs: Optional<T>, rhs: E) throws -> T {
    switch lhs {
    case .some(let value):
        return value
    case .none:
        throw rhs
    }
}
