// Copyright (c). Gem Wallet. All rights reserved.

import Gemstone
import Primitives
import BigInt

public struct GetewayService {
    let chain: Primitives.Chain
    let gateway: GemGateway
    
    public init(
        chain: Primitives.Chain
    ) {
        self.chain = chain
        self.gateway = GemGateway(
            chain: chain.rawValue
            //rpcProvider: NativeProvider(nodeProvider: nodeProvider)
        )
    }
}

// MARK: - ChainBalanceable

extension GetewayService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> Primitives.AssetBalance {
        try await gateway.coinBalance(address: address).map()
    }

    public func tokenBalance(for address: String, tokenIds: [Primitives.AssetId]) async throws -> [Primitives.AssetBalance] {
        try await gateway.tokenBalance(address: address, tokenIds: tokenIds.map(\.id)).map {
            try $0.map()
        }
    }

    public func getStakeBalance(for address: String) async throws -> Primitives.AssetBalance? {
        try await gateway.getStakeBalance(address: address)?.map()
    }
}

extension AssetBalanceWrapper {
    func map() throws -> Primitives.AssetBalance {
        Primitives.AssetBalance(
            assetId: try AssetId(id: assetId),
            balance: try balance.map()
        )
    }
}

extension BalanceWrapper {
    func map() throws -> Primitives.Balance {
        Primitives.Balance(
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
