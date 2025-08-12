// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import ChainService
import Primitives

public struct PerpetualProviderFactory {
    
    private let nodeProvider: any NodeURLFetchable
    
    public init(nodeProvider: any NodeURLFetchable) {
        self.nodeProvider = nodeProvider
    }
    
    public func createProvider(chain: Chain = .hyperCore) -> PerpetualProvidable {
        HyperCorePerpetualProvider(
            hyperCoreService: HyperCoreService(
                provider: ProviderFactory.create(with: nodeProvider.node(for: chain)),
                cacheService: BlockchainCacheService(chain: chain),
                config: HyperCoreServiceConfigProvider.createConfig()
            )
        )
    }
}
