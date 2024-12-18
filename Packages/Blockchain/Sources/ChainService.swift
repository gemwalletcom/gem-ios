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
            SolanaService(chain: chain, provider: ProviderFactory.create(with: url))
        case .ethereum:
            EthereumService(
                chain: EVMChain(rawValue: chain.rawValue)!,
                provider: ProviderFactory.create(with: url)
            )
        case .cosmos:
            CosmosService(chain: CosmosChain(rawValue: chain.rawValue)!, provider: ProviderFactory.create(with: url))
        case .ton:
            TonService(chain: chain, provider: ProviderFactory.create(with: url))
        case .tron:
            TronService(chain: chain, provider: ProviderFactory.create(with: url))
        case .bitcoin:
            BitcoinService(
                chain: BitcoinChain(rawValue: chain.rawValue)!,
                provider: ProviderFactory.create(with: url)
            )
        case .aptos:
            AptosService(chain: chain, provider: ProviderFactory.create(with: url))
        case .sui:
            SuiService(chain: chain, provider: ProviderFactory.create(with: url))
        case .xrp:
            XRPService(chain: chain, provider: ProviderFactory.create(with: url))
        case .near:
            NearService(chain: chain, provider: ProviderFactory.create(with: url))
        case .stellar:
            StellarService(chain: chain, provider: ProviderFactory.create(with: url))
        }
    }
}
