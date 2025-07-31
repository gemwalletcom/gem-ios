// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ChainService
import Primitives

public struct BalanceFetcher: Sendable {
    private let chainServiceFactory: ChainServiceFactory
    
    public init(chainServiceFactory: ChainServiceFactory) {
        self.chainServiceFactory = chainServiceFactory
    }
    
    public func getBalance(
        assetId: AssetId,
        address: String
    ) async throws -> AssetBalance  {
        switch assetId.type {
        case .native:
            return try await getCoinBalance(
                chain: assetId.chain,
                address: address
            )
        case .token:
            guard let balance = try await getTokenBalance(
                chain: assetId.chain,
                address: address,
                tokenIds: [assetId.identifier]
            ).first else { throw AnyError("no balance available") }
            return balance
        }
    }
    
    func getCoinBalance(
        chain: Chain,
        address: String
    ) async throws -> AssetBalance {
        try await chainServiceFactory
            .service(for: chain)
            .coinBalance(for: address)
    }

    func getCoinStakeBalance(
        chain: Chain,
        address: String
    ) async throws -> AssetBalance? {
        try await chainServiceFactory
            .service(for: chain)
            .getStakeBalance(for: address)
    }

    func getTokenBalance(
        chain: Chain,
        address: String,
        tokenIds: [String]
    ) async throws -> [AssetBalance] {
        try await chainServiceFactory
            .service(for: chain)
           .tokenBalance(for: address, tokenIds: tokenIds.compactMap { try? AssetId(id: $0) })
    }
}
