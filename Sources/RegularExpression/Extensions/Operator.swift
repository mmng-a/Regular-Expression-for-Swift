
infix operator !!

/// If value is nil, this function throws error.
/// - Parameters:
///   - lhs: A value
///   - rhs: An error
/// - Throws: Throws rhs
/// - Returns: Non-nil lhs
func !!<T, E: Error>(lhs: Optional<T>, rhs: E) throws -> T {
    switch lhs {
    case .some(let value):
        return value
    case .none:
        throw rhs
    }
}
