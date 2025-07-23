// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Blockchain
import SwiftHTTPClient

public protocol PerpetualServiceable: Sendable {
    func getPositions(walletId: WalletId) async throws -> [PerpetualPosition]
    func getMarkets() async throws -> [Perpetual]
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
    
    public func getMarkets() async throws -> [Perpetual] {
        return try store.getPerpetuals()
    }
    
    public func updatePositions(wallet: Wallet) async throws {
        for provider in providers {
            Task {
                await updatePositionsForProvider(provider, wallet: wallet)
            }
        }
    }
    
    private func updatePositionsForProvider(_ provider: PerpetualProvidable, wallet: Wallet) async {
        do {
            let positions = try await provider.getPositions(wallet: wallet)
            try await syncProviderPositions(
                positions: positions,
                provider: provider.provider(),
                walletId: wallet.id
            )
        } catch {
            print("PerpetualService: Failed to update positions from provider: \(error)")
        }
    }
    
    private func syncProviderPositions(positions: [PerpetualPosition], provider: PerpetualProvider, walletId: String) async throws {
        let existingPositions = try store.getPositions(walletId: walletId, provider: provider)
        let existingIds = existingPositions.map { $0.id }.asSet()
        let newIds = positions.map { $0.id }.asSet()
        
        let changes = SyncDiff.calculate(
            primary: .remote,
            local: existingIds,
            remote: newIds
        )
        
        try store.diffPositions(
            deleteIds: changes.toDelete.asArray(),
            positions: positions,
            walletId: walletId
        )
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
