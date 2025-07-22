// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Blockchain
import SwiftHTTPClient

public protocol PerpetualServiceable: Sendable {
    func getPositions(walletId: WalletId) async throws -> [PerpetualPosition]
    func updatePositions(wallet: Wallet) async throws
    func updateMarkets() async throws
}

public struct PerpetualService: PerpetualServiceable {
    
    private let store: PerpetualStore
    private let providers: [PerpetualProvidable]
    
    public init(
        store: PerpetualStore,
        providerFactory: PerpetualProviderFactory
    ) {
        self.store = store
        self.providers = providerFactory.createProviders()
    }
    
    public func getPositions(walletId: WalletId) async throws -> [PerpetualPosition] {
        return try store.getPositions(walletId: walletId.id)
    }
    
    public func updatePositions(wallet: Wallet) async throws {
        let allPositions = await fetchPositionsFromAllProviders(wallet: wallet)
        
        let existingPositions = try store.getPositions(walletId: wallet.id)
        let existingPositionIds = Set(existingPositions.map { $0.id })
        
        let newPositionIds = Set(allPositions.map { $0.id })
        let positionsToDelete = existingPositionIds.subtracting(newPositionIds)
        
        try store.deletePositions(ids: Array(positionsToDelete))
        try store.upsertPositions(allPositions, walletId: wallet.id)
    }
    
    private func fetchPositionsFromAllProviders(wallet: Wallet) async -> [PerpetualPosition] {
        await withTaskGroup(of: [PerpetualPosition].self) { group in
            for provider in providers {
                group.addTask { [provider] in
                    do {
                        return try await provider.getPositions(wallet: wallet)
                    } catch {
                        print("PerpetualService: Failed to fetch positions from provider: \(error)")
                        return []
                    }
                }
            }
            
            var allPositions: [PerpetualPosition] = []
            for await positions in group {
                allPositions.append(contentsOf: positions)
            }
            return allPositions
        }
    }
    
    public func updateMarkets() async throws {
        let allMarkets = await fetchMarketsFromAllProviders()
        try store.upsertPerpetuals(allMarkets)
    }
    
    private func fetchMarketsFromAllProviders() async -> [Perpetual] {
        await withTaskGroup(of: [Perpetual].self) { group in
            for provider in providers {
                group.addTask { [provider] in
                    do {
                        return try await provider.getMarkets()
                    } catch {
                        print("PerpetualService: Failed to fetch markets from provider: \(error)")
                        return []
                    }
                }
            }
            
            var allMarkets: [Perpetual] = []
            for await markets in group {
                allMarkets.append(contentsOf: markets)
            }
            return allMarkets
        }
    }
}
