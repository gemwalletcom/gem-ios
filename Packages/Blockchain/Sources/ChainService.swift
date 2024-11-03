// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt

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
            return SolanaService(chain: chain, provider: ProviderFactory.create(with: url))
        case .ethereum:
            return EthereumService(
                chain: EVMChain(rawValue: chain.rawValue)!,
                provider: ProviderFactory.create(with: url)
            )
        case .cosmos:
            return CosmosService(chain: CosmosChain(rawValue: chain.rawValue)!, provider: ProviderFactory.create(with: url))
        case .ton:
            return TonService(chain: chain, provider: ProviderFactory.create(with: url))
        case .tron:
            return TronService(chain: chain, provider: ProviderFactory.create(with: url))
        case .bitcoin:
            return BitcoinService(
                chain: BitcoinChain(rawValue: chain.rawValue)!,
                provider: ProviderFactory.create(with: url)
            )
        case .aptos:
            return AptosService(chain: chain, provider: ProviderFactory.create(with: url))
        case .sui:
            return SuiService(chain: chain, provider: ProviderFactory.create(with: url))
        case .xrp:
            return XRPService(chain: chain, provider: ProviderFactory.create(with: url))
        case .near:
            return NearService(chain: chain, provider: ProviderFactory.create(with: url))
        }
    }
}
