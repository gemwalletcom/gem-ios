// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

struct EstimateFeeService: Sendable {

    init() {}

    func provider(chain: Primitives.Chain) throws -> any GemGatewayEstimateFee {
        switch chain.type {
        case .bitcoin: BitcoinService(chain: try BitcoinChain(id: chain.rawValue))
        case .cardano: CardanoService()
        case .polkadot: PolkadotService()
        default: EmptyService()
        }
    }

    func getFee(chain: Gemstone.Chain, input: Gemstone.GemTransactionLoadInput) async throws -> Gemstone.GemTransactionLoadFee? {
        try await provider(chain: try chain.map()).getFee(chain: chain, input: input)
    }

    func getFeeData(chain: Gemstone.Chain, input: Gemstone.GemTransactionLoadInput) async throws -> String? {
        try await provider(chain: try chain.map()).getFeeData(chain: chain, input: input)
    }
}

final class EmptyService: Sendable {

    init() {

    }
}

extension EmptyService: GemGatewayEstimateFee {
    public func getFee(chain: Gemstone.Chain, input: Gemstone.GemTransactionLoadInput) async throws -> Gemstone.GemTransactionLoadFee? {
        return .none
    }

    public func getFeeData(chain: Gemstone.Chain, input: GemTransactionLoadInput) async throws -> String? {
        .none
    }
}
