// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import ChainService
import Primitives
import NativeProviderService

public struct PerpetualProviderFactory {
    
    private let nodeProvider: any NodeURLFetchable
    
    public init(nodeProvider: any NodeURLFetchable) {
        self.nodeProvider = nodeProvider
    }
    
    public func createProvider(chain: Chain = .hyperCore) -> PerpetualProvidable {
        HyperCorePerpetualProvider(
            hyperCoreService: HyperCoreService(
                provider: ProviderFactory.create(with: nodeProvider.node(for: chain)),
                gateway: GetewayService(
                    provider: NativeProvider(nodeProvider: nodeProvider)
                ),
                cacheService: BlockchainCacheService(chain: chain),
                config: HyperCoreConfig.create()
            )
        )
    }
}
