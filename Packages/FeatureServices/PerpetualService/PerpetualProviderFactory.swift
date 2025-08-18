// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import Primitives
import NativeProviderService

public struct PerpetualProviderFactory {
    
    private let nodeProvider: any NodeURLFetchable
    
    public init(nodeProvider: any NodeURLFetchable) {
        self.nodeProvider = nodeProvider
    }
    
    public func createProvider(chain: Chain = .hyperCore) -> PerpetualProvidable {
        GatewayPerpetualProvider(
            gateway: GatewayService(
                provider: NativeProvider(nodeProvider: nodeProvider)
            ),
            chain: chain
        )
    }
}
