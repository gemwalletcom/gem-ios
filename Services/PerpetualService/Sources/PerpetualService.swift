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
    func getCandlesticks(coin: String, startTime: Int, endTime: Int, interval: String) async throws -> [ChartCandleStick]
}

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
        let markets = try await provider.getMarkets()
        try store.upsertPerpetuals(markets)
    }
    
    public func getCandlesticks(coin: String, startTime: Int, endTime: Int, interval: String = "1m") async throws -> [ChartCandleStick] {
        return try await provider.getCandlesticks(
            coin: coin,
            startTime: startTime,
            endTime: endTime,
            interval: interval
        )
    }
}
