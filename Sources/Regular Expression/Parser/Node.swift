
enum Node {
    case null
    case character(Character)
    indirect case `repeat`(Node, Optional<ClosedRange<UInt>>)
    case concat([Node])
    case union([Node])
}

extension Node {
    
    func assemble(_ context: inout Context) -> NFAFlag {
        switch self {
        case .null:
            return assembleNull(&context)
            
        case .character(let char):
            var flag = NFAFlag()
            let (s1, s2) = (context.nextState(), context.nextState())
            flag.connect(from: s1, to: s2, with: char)
            flag.start = s1
            flag.accepts = [s2]
            return flag
            
        case .repeat(let node, nil):        // star
            let originalFlag = node.assemble(&context)
            var flag = originalFlag.newSkelton()
            
            for state in originalFlag.accepts {
                flag.connect(from: state, to: originalFlag.start, with: nil)
            }
            let state = context.nextState()
            flag.connect(from: state, to: originalFlag.start, with: nil)
            
            flag.start = state
            flag.accepts = originalFlag.accepts.union([state])
            return flag
            
        // TODO: 高速化
        case .repeat(let node, let .some(range)):
            let unionNode = Node.union([node, .null])
            let lowerNodes = Array(repeating: node, count: Int(range.lowerBound))
            let upperNodes = Array(repeating: unionNode, count: range.count - 1)
            
            return assembleConcat(
                nodes: lowerNodes + upperNodes,
                context: &context
            )
            
        case .concat(let nodes):
            return assembleConcat(nodes: nodes, context: &context)
            
        case .union(let nodes):
            return assembleUnion(nodes: nodes, context: &context)
        }
    }
    
    fileprivate func assembleNull(_ context: inout Context) -> NFAFlag {
        var flag = NFAFlag()
        let (s1, s2) = (context.nextState(), context.nextState())
        flag.connect(from: s1, to: s2, with: nil)
        flag.start = s1
        flag.accepts = [s2]
        return flag
    }
    
    fileprivate func assembleConcat(nodes: [Node], context: inout Context) -> NFAFlag {
        guard !nodes.isEmpty else { return assembleNull(&context) }
        
        let flags = nodes.map { $0.assemble(&context) }
        var flag = flags[1...].reduce(flags[0], NFAFlag.compose)
        
        if flags.count >= 2 {
            for (first, second) in zip(flags[..<flags.endIndex], flags[1...]) {
                for state in first.accepts {
                    flag.connect(from: state, to: second.start, with: nil)
                }
            }
        }
        
        flag.start = flags.first!.start
        flag.accepts = flags.last!.accepts
        return flag
    }
    
    fileprivate func assembleUnion(nodes: [Node], context: inout Context) -> NFAFlag {
        guard !nodes.isEmpty else { return assembleNull(&context) }
        
        let flags = nodes.map { $0.assemble(&context) }
        var flag = flags[1...].reduce(flags[0], NFAFlag.compose)
        
        let state = context.nextState()
        for otherFlag in flags {
            flag.connect(from: state, to: otherFlag.start, with: nil)
        }
        
        flag.start = state
        flag.accepts = Set(flags.flatMap(\.accepts))
        return flag
    }
    
    var string: String {
        switch self {
        case .null:                  return ""
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
    
}

extension Node: CustomStringConvertible {
    var description: String {
        switch self {
        case .null:
            return "Node.null"
        case .character(let c):
            return c.description
        case .concat(let nodes):
            let nodesDescription = nodes
                .map(\.description)
                .joined(separator: ", ")
            return "Node.concat([\(nodesDescription)])"
        case .union(let nodes):
            let nodesDescription = nodes
                .map(\.description)
                .joined(separator: ", ")
            return "Node.union([\(nodesDescription)])"
        case .repeat(let node, let range):
            return "Node.repeat(\(node), \(range?.description ?? "nil"))"
        }
    }
}
