
struct Context {
    var stateCount = 0
    
    // `new_state`
    mutating func nextState() -> Int {
        self.stateCount += 1
        return stateCount
    }
}
