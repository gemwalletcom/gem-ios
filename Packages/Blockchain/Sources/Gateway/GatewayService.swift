// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt
import NativeProviderService

public struct GetewayService: Sendable {
    let gateway: GemGateway
    
    public init(
        provider: NativeProvider
    ) {
        self.gateway = GemGateway(provider: provider)
    }
}

// MARK: - ChainBalanceable

extension GetewayService {
    public func coinBalance(chain: Primitives.Chain, address: String) async throws -> AssetBalance {
        try await gateway.coinBalance(chain: chain.rawValue, address: address).map()
    }

    public func tokenBalance(chain: Primitives.Chain, address: String, tokenIds: [Primitives.AssetId]) async throws -> [AssetBalance] {
        try await gateway.tokenBalance(chain: chain.rawValue, address: address, tokenIds: tokenIds.map(\.id)).map {
            try $0.map()
        }
    }

    public func getStakeBalance(chain: Primitives.Chain, address: String) async throws -> AssetBalance? {
        try await gateway.getStakeBalance(chain: chain.rawValue, address: address)?.map()
    }
}

extension GemAssetBalance {
    func map() throws -> AssetBalance {
        AssetBalance(
            assetId: try AssetId(id: assetId),
            balance: try balance.map()
        )
    }
}

extension GemBalance {
    func map() throws -> Balance {
        Balance(
            available: try BigInt.from(string: available),
            frozen: try BigInt.from(string: frozen),
            locked: try BigInt.from(string: locked),
            staked: try BigInt.from(string: staked),
            pending: try BigInt.from(string: pending),
            rewards: try BigInt.from(string: rewards),
            reserved: try BigInt.from(string: reserved),
            withdrawable: try BigInt.from(string: withdrawable)
        )
    }
}
