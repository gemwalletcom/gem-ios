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
}

// MARK: - Factory

extension ChainService {
    public static func service(chain: Chain, with url: URL) -> ChainServiceable {
        switch chain.type {
        case .ethereum:
            EthereumService(
                chain: EVMChain(rawValue: chain.rawValue)!,
                provider: ProviderFactory.create(with: url)
            )
        case .sui:
            SuiService(
                chain: chain, 
                provider: ProviderFactory.create(with: url),
                gateway: GatewayService(provider: NativeProvider(url: url))
            )
        case .aptos,
            .algorand,
            .xrp,
            .stellar,
            .near,
            .cosmos,
            .ton,
            .polkadot,
            .bitcoin,
            .cardano,
            .tron,
            .solana,
            .hyperCore:
            GatewayChainService(
                chain: chain,
                gateway: GatewayService(provider: NativeProvider(url: url))
            )
        }
    }
}
