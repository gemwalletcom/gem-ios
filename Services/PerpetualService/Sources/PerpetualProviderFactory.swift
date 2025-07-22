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
    
    public func createProviders() -> [PerpetualProvidable] {
        [createProvider(for: .hypercore)]
    }
    
    private func createProvider(for type: PerpetualProvider) -> PerpetualProvidable {
        switch type {
        case .hypercore:
            return HyperCorePerpetualProvider(
                hyperCoreService: HyperCoreService(
                    provider: ProviderFactory.create(with: nodeProvider.node(for: .hyperCore))
                )
            )
        }
    }
}
