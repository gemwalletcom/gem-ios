// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Blockchain

public protocol NodeURLFetchable {
    func node(for chain: Chain) -> URL
}

public final class ChainServiceFactory {

    let nodeProvider: NodeURLFetchable
    
    init(nodeProvider: NodeURLFetchable) {
        self.nodeProvider = nodeProvider
    }
    
    func service(for chain: Chain) -> ChainServiceable {
        return ChainService.service(
            chain: chain,
            with: nodeProvider.node(for: chain)
        )
    }
}
