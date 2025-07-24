// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Blockchain
import SwiftHTTPClient

public struct PerpetualService: PerpetualServiceable {
    
    private let store: PerpetualStore
    private let provider: PerpetualProvidable
    
    public init(
        store: PerpetualStore,
        providerFactory: PerpetualProviderFactory
    ) {
        self.store = store
        self.provider = providerFactory.createProvider()
    }
    
    public func getPositions(walletId: WalletId) async throws -> [PerpetualPosition] {
        return try store.getPositions(walletId: walletId.id)
    }
    
    public func getMarkets() async throws -> [Perpetual] {
        return try store.getPerpetuals()
    }
    
    public func updatePositions(wallet: Wallet) async throws {
        guard let account = wallet.accounts.first(where: { 
            $0.chain == .arbitrum || $0.chain == .hyperCore
        }) else {
            return
        }
        
        let positions = try await provider.getPositions(address: account.address, walletId: wallet.id)
        try await syncProviderPositions(
            positions: positions,
            provider: provider.provider(),
            walletId: wallet.id
        )
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
        let markets = try await provider.getPerpetuals()
        try store.upsertPerpetuals(markets)
    }
    
    public func updateMarket(symbol: String) async throws {
        let market = try await provider.getPerpetual(symbol: symbol)
        try store.upsertPerpetuals([market])
    }
    
    public func candlesticks(symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick] {
        return try await provider.getCandlesticks(symbol: symbol, period: period)
    }
}
