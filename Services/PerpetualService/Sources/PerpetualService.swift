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
        let positions = try await provider.getPositions(wallet: wallet)
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
        let interval = hyperliquidInterval(for: period)
        let endTime = Int(Date().timeIntervalSince1970 * 1000)
        let startTime = endTime - (60 * interval.durationMs)
        
        return try await provider.getCandlesticks(
            coin: symbol,
            startTime: startTime,
            endTime: endTime,
            interval: interval.name
        )
    }
    
    private func hyperliquidInterval(for period: ChartPeriod) -> (name: String, durationMs: Int) {
        switch period {
        case .hour: ("1m", 60_000)
        case .day: ("5m", 300_000)
        case .week: ("1h", 3_600_000)
        case .month: ("4h", 14_400_000)
        case .year: ("1d", 86_400_000)
        case .all: ("1w", 604_800_000)
        }
    }
}
