
extension Array where Element == Character {
    
    init(from character1: Character, to character2: Character) {
        let a = character1.asciiCode
        let b = character2.asciiCode
        self = (a...b).compactMap { Character(asciiCode: $0) }
    }
}

fileprivate extension Character {
    
    init?(asciiCode: UInt32) {
        guard let scalar = UnicodeScalar(asciiCode) else {
            return nil
        }
        self = Character(scalar)
    }
    
    var asciiCode: UInt32 {
        let string = String(self)
        let scalars = string.unicodeScalars
        return scalars[scalars.startIndex].value
    }
    
}
