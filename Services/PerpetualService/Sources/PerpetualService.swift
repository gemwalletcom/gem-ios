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
        let endTime = Int(Date().timeIntervalSince1970 * 1000)
        let candleCount = 60
        let interval = intervalForPeriod(period)
        let intervalDuration = intervalDurationInSeconds(for: interval) * 1000
        let startTime = endTime - (candleCount * intervalDuration)
        
        return try await provider.getCandlesticks(
            coin: symbol,
            startTime: startTime,
            endTime: endTime,
            interval: interval
        )
    }
    
    private func intervalForPeriod(_ period: ChartPeriod) -> String {
        switch period {
        case .hour: "1m"
        case .day: "5m"
        case .week: "1h"
        case .month: "4h"
        case .year: "1d"
        case .all: "1w"
        }
    }
    
    private func intervalDurationInSeconds(for interval: String) -> Int {
        switch interval {
        case "1m": 60
        case "5m": 5 * 60
        case "1h": 60 * 60
        case "4h": 4 * 60 * 60
        case "1d": 24 * 60 * 60
        case "1w": 7 * 24 * 60 * 60
        default: 60
        }
    }
}
