
extension ClosedRange {
  static func at(_ point: Bound) -> Self {
    point...point
  }
}
