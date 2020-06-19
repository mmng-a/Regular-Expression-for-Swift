
struct Context {
    var stateCount = 0
    
    mutating func nextState() -> Int {
        self.stateCount += 1
        return stateCount
    }
}
