// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import NativeProviderService

public struct ChainService {
    
    let chain: Chain
    let url: URL

    public init(
        chain: Chain,
        url: URL
    ) {
        self.chain = chain
        self.url = url
    }
    
    public static func service(chain: Chain, with url: URL) -> ChainServiceable {
        GatewayChainService(
            chain: chain,
            gateway: GatewayService(provider: NativeProvider(url: url))
        )
    }
}
