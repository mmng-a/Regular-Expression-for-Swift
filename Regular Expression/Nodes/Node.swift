//
//  Node2.swift
//  Regular Expression
//
//  Created by Masashi Aso on 2020/06/16.
//  Copyright © 2020 Masashi Aso. All rights reserved.
//

enum Node {
    case character(Character)
    case null
    indirect case `repeat`(Node, Optional<ClosedRange<UInt>>)
    case concat([Node])
    case union([Node])
}

extension Node: NodeType {
    
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
            guard range.lowerBound == 0 && range.upperBound == 0 else {
                return assembleNull(&context)
            }
            
            let unionNode = Node.union([node, .null])
            let lowerNodes = Array(repeating: node, count: Int(range.lowerBound))
            let upperNodes = Array(repeating: unionNode, count: range.count - 1)
            
            return assembleConcat(
                nodes: lowerNodes + upperNodes,
                context: &context
            )
            
        case .concat(let nodes):
            guard !nodes.isEmpty else { return assembleNull(&context) }
            return assembleConcat(nodes: nodes, context: &context)
            
        case .union(let nodes):
            guard !nodes.isEmpty else { return assembleNull(&context) }
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
        let flags = nodes.map { $0.assemble(&context) }
        var flag = flags[1...].reduce(flags[0], NFAFlag.compose)
        
        for state in flags[0].accepts {
            flag.connect(from: state, to: flags.last!.start, with: nil)
        }
        flag.start = flags.first!.start
        flag.accepts = flags.last!.accepts
        
        return flag
    }
    
    fileprivate func assembleUnion(nodes: [Node], context: inout Context) -> NFAFlag {
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
    
    func toString() -> String {
        ""
    }
}
