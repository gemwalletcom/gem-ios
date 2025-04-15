// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ChainService
import Primitives

public struct NodeURLFetchableMock: NodeURLFetchable {
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }

    public func node(for chain: Chain) -> URL {
        url
    }
}
