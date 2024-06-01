// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Node: Identifiable {
    public var id: String {
        return "\(url)"
    }
}

extension Node: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.url == rhs.url
    }
}

extension ChainNode: Identifiable {
    public var id: String {
        return "\(chain)\(node.url)"
    }
}

extension ChainNode: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(chain)
        hasher.combine(node.url)
    }
    
    public static func == (lhs: ChainNode, rhs: ChainNode) -> Bool {
        return lhs.chain == rhs.chain && lhs.node.url == rhs.node.url
    }
}
