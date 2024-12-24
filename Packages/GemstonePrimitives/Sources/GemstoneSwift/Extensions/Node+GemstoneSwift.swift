// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Gemstone

extension Gemstone.Node {
    public var node: Primitives.Node {
        let priority = switch priority {
        case .high: 10
        case .medium: 5
        case .low: 1
        case .inactive: -1
        }
        let status: NodeState = priority > 0 ? .active : .inactive

        return Primitives.Node(
            url: url,
            status: status,
            priority: priority.asInt32
        )
    }
}
