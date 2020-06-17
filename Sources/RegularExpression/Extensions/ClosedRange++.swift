
extension ClosedRange {
    init(at point: Bound) {
        self = point...point
    }
}
