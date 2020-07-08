
struct JoinedCollection<Base> where Base: Collection {
    
    private var collections: [Base]
    
    init(_ first: Base, _ second: Base, _ more: Base...) {
        collections = [first, second] + more
    }
}

extension JoinedCollection: Sequence {
    
    typealias Element = Base.Element
    
    struct Iterator: IteratorProtocol {
        typealias Element = Base.Element
        
        var iterators: [Base.Iterator]
        init(_ iterators: [Base.Iterator]) {
            self.iterators = iterators
        }
        
        mutating func next() -> Element? {
            for i in iterators.indices {
                guard let value = iterators[i].next() else { continue }
                return value
            }
            return nil
        }
    }
    
    func makeIterator() -> Iterator {
        Iterator(collections.map { $0.makeIterator() })
    }
}

extension JoinedCollection: Collection {
    
    typealias Index = Int
    
    var count: Int {
        collections.map(\.count).reduce(0, +)
    }
    
    subscript(position: Index) -> Element {
        var position = position
        var collectionIndex = 0
        var index: Int = 0
        for count in collections.map(\.count) {
            if position - count > 0 {
                position -= count
                collectionIndex += 1
            } else {
                index = position
                break
            }
        }
        
        assert(collections.indices.contains(collectionIndex), "Index out of range")
        let collection = collections[collectionIndex]
        let i = collection.index(collection.startIndex, offsetBy: index)
        assert(collection.indices.contains(i), "Index out of range")
        return collection[i]
    }
    
    var startIndex: Int { 0 }
    var endIndex  : Int { collections.map(\.count).reduce(0, +) }
    
    func index(after i: Int) -> Int {
        i + 1
    }
    
}

