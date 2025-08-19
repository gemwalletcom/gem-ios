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
        case .solana:
            SolanaService(
                chain: chain, 
                provider: ProviderFactory.create(with: url),
                gateway: GatewayService(provider: NativeProvider(url: url))
            )
        case .ethereum:
            EthereumService(
                chain: EVMChain(rawValue: chain.rawValue)!,
                provider: ProviderFactory.create(with: url)
            )
        case .tron:
            TronService(chain: chain, provider: ProviderFactory.create(with: url))
        case .bitcoin:
            BitcoinService(
                chain: BitcoinChain(rawValue: chain.rawValue)!,
                gateway: GatewayService(provider: NativeProvider(url: url))
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
            .ton:
            GatewayChainService(
                chain: chain,
                gateway: GatewayService(provider: NativeProvider(url: url))
            )
        case .polkadot:
            PolkadotService(
                chain: chain,
                provider: ProviderFactory.create(with: url),
                gateway: GatewayService(provider: NativeProvider(url: url))
            )
        case .cardano:
            CardanoService(
                chain: chain,
                gateway: GatewayService(provider: NativeProvider(url: url))
            )
        case .hyperCore:
            HyperCoreService(
                chain: chain,
                provider: ProviderFactory.create(with: url),
                gateway: GatewayService(provider: NativeProvider(url: url)),
                cacheService: BlockchainCacheService(chain: chain),
                config: HyperCoreConfig.create()
            )
        }
    }
}
