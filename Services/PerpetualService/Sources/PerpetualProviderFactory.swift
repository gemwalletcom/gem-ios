// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import ChainService
import Primitives
import SwiftHTTPClient

public struct PerpetualProviderFactory {
    
    private let nodeProvider: any NodeURLFetchable
    
    public init(nodeProvider: any NodeURLFetchable) {
        self.nodeProvider = nodeProvider
    }
    
    public func createProvider() -> PerpetualProvidable {
        HyperCorePerpetualProvider(
            hyperCoreService: HyperCoreService(
                provider: ProviderFactory.create(with: nodeProvider.node(for: .hyperCore))
            )
        )
    }
}
