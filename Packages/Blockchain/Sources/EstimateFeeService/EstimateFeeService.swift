// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

public struct EstimateFeeService: Sendable {
    
    public init() {}
    
    public func provider(chain: Primitives.Chain) throws -> any GemGatewayEstimateFee {
        switch chain.type {
        case .bitcoin: BitcoinService(chain: try BitcoinChain(id: chain.rawValue))
        case .cardano: CardanoService()
        case .polkadot: PolkadotService()
        default: throw AnyError("no get data")
        }
    }
    
    public func getFee(chain: Gemstone.Chain, input: Gemstone.GemTransactionLoadInput) async throws -> Gemstone.GemTransactionLoadFee? {
        try await provider(chain: try Chain(id: chain)).getFee(chain: chain, input: input)
    }
    
    public func getFeeData(chain: Gemstone.Chain, input: Gemstone.GemTransactionLoadInput) async throws -> String? {
        try await provider(chain: try Chain(id: chain)).getFeeData(chain: chain, input: input)
    }
}
