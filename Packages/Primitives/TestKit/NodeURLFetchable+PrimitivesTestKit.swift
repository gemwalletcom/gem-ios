// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@testable import Primitives

public extension NodeURLFetchable {
    static func mock() -> NodeURLFetchable {
        MockNodeURLFetchable()
    }
}

public struct MockNodeURLFetchable: NodeURLFetchable {
    public func node(for chain: Chain) -> URL {
        URL(string: "https://mock-node.example.com")!
    }
    
    public init() {}
}