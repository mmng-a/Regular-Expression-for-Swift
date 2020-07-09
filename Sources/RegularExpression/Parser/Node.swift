
enum Node {
    case character(Char)
    indirect case `repeat`(Node, Optional<ClosedRange<UInt>>)
    case concat([Node])
    case union([Node])
}

extension Node {
    
    func assemble(_ context: inout Context) -> NFAFlag {
        switch self {
        case .character(let char):
            return assembleChar(char, context: &context)
            
        case .repeat(let node, nil):
            let originalFlag = node.assemble(&context)
            var flag = originalFlag.createSkelton()
            
            for state in originalFlag.accepts {
                flag.connect(from: state, to: originalFlag.start, with: .null)
            }
            let state = context.nextState()
            flag.connect(from: state, to: originalFlag.start, with: .null)
            
            flag.start = state
            flag.accepts = originalFlag.accepts.union([state])
            return flag
            
        case .repeat(let node, let .some(range)):
            let mustNodes   = repeatElement(node, count: Int(range.lowerBound))
            let optionNodes = repeatElement(Node.union([node, .character(.null)]), count: range.count - 1)
            let joinedNodes: FlattenCollection = [mustNodes, optionNodes].joined()
            return assembleConcat(nodes: joinedNodes, context: &context)
            
        case .concat(let nodes):
            return assembleConcat(nodes: nodes, context: &context)
            
        case .union(let nodes):
            return assembleUnion(nodes: nodes, context: &context)
        }
    }
    
    fileprivate func assembleChar(_ char: Char, context: inout Context) -> NFAFlag {
        var flag = NFAFlag()
        let (s1, s2) = (context.nextState(), context.nextState())
        flag.connect(from: s1, to: s2, with: char)
        flag.start = s1
        flag.accepts = [s2]
        return flag
    }
    
    /// - Note: O(*n*) where n is nodes.count
    fileprivate func assembleConcat<C>(nodes: C, context: inout Context) -> NFAFlag
        where C: Collection, C.Element == Node
    {
        guard !nodes.isEmpty else { return assembleChar(.null, context: &context) }
        
        let flags = nodes.map { $0.assemble(&context) }
        var flag = flags[1...].reduce(flags[0], NFAFlag.compose)
        
        if flags.count >= 2 {
            for (first, second) in zip(flags[..<flags.endIndex], flags[1...]) {
                for state in first.accepts {
                    flag.connect(from: state, to: second.start, with: .null)
                }
            }
        }
        
        flag.start = flags.first!.start
        flag.accepts = flags.last!.accepts
        return flag
    }
    
    fileprivate func assembleUnion<C>(nodes: C, context: inout Context) -> NFAFlag
        where C: Collection, C.Element == Node
    {
        guard !nodes.isEmpty else { return assembleChar(.null, context: &context) }
        
        let flags = nodes.map { $0.assemble(&context) }
        var flag = flags[1...].reduce(flags[0], NFAFlag.compose)
        
        let state = context.nextState()
        for otherFlag in flags {
            flag.connect(from: state, to: otherFlag.start, with: .null)
        }
        
        flag.start = state
        flag.accepts = Set(flags.flatMap(\.accepts))
        return flag
    }
    
    var string: String {
        switch self {
        case .character(let char):   return "\(char)"
        case .concat(let nodes):     return nodes.map(\.string).joined()
        case .union (let nodes):     return nodes.map(\.string).joined(separator: "|")
        case .repeat(let node, nil): return node.string + "*"
        case .repeat(let node, let .some(range)) where range.count == 1:
            return node.string + "{\(range.lowerBound)}"
        case .repeat(let node, let .some(range)):
            return node.string + "{\(range.lowerBound),\(range.upperBound)}"
        }
    }
}

extension Node {
    
    static func star(_ node: Node) -> Node {
        Node.repeat(node, nil)
    }
    
    static func plus(_ node: Node) -> Node {
        Node.concat([node, .star(node)])
    }
    
    static func question(_ node: Node) -> Node {
        Node.union([node, .character(.null)])
    }
    
    static func character(_ character: Character) -> Node {
        Node.character(.character(character))
    }
}

extension Node: CustomStringConvertible {
    var description: String {
        switch self {
        case .character(let c):  return c.description
        case .union(let nodes):  return "Node.union([\(nodes)])"
        case .concat(let nodes): return "Node.concat([\(nodes)])"
        case .repeat(let node, let range):
            return "Node.repeat(\(node), \(range?.description ?? "nil"))"
        }
    }
}
