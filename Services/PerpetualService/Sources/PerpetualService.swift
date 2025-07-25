// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Blockchain
import SwiftHTTPClient

public struct PerpetualService: PerpetualServiceable {
    
    private let store: PerpetualStore
    private let assetStore: AssetStore
    private let balanceStore: BalanceStore
    private let provider: PerpetualProvidable
    
    public init(
        store: PerpetualStore,
        assetStore: AssetStore,
        balanceStore: BalanceStore,
        providerFactory: PerpetualProviderFactory
    ) {
        self.store = store
        self.assetStore = assetStore
        self.balanceStore = balanceStore
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
        
        // First, ensure markets are up to date
        try await updateMarkets()
        
        let positions = try await provider.getPositions(address: account.address, walletId: wallet.id)
        
        // Ensure balance records exist for all perpetual assets
        let perpetualsData = try await provider.getPerpetualsData()
        let assetIds = perpetualsData.map { $0.asset.id }
        try balanceStore.addMissingBalances(walletId: wallet.id, assetIds: assetIds, isEnabled: false)
        
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
        let perpetualsData = try await provider.getPerpetualsData()
        let perpetuals = perpetualsData.map { $0.perpetual }
        let assets = perpetualsData.map { createPerpetualAssetBasic(from: $0.asset) }
        
        try assetStore.add(assets: assets)
        try store.upsertPerpetuals(perpetuals)
    }
    
    public func updateMarket(symbol: String) async throws {
        let perpetualsData = try await provider.getPerpetualsData()
        
        guard let data = perpetualsData.first(where: { $0.perpetual.name == symbol }) else {
            throw PerpetualError.marketNotFound(symbol: symbol)
        }
        
        let asset = createPerpetualAssetBasic(from: data.asset)
        try assetStore.add(assets: [asset])
        try store.upsertPerpetuals([data.perpetual])
    }
    
    public func candlesticks(symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick] {
        return try await provider.getCandlesticks(symbol: symbol, period: period)
    }
    
    private func createPerpetualAssetBasic(from asset: Asset) -> AssetBasic {
        AssetBasic(
            asset: asset,
            properties: AssetProperties(
                isEnabled: false,
                isBuyable: false,
                isSellable: false,
                isSwapable: false,
                isStakeable: false,
                stakingApr: nil
            ),
            score: AssetScore(rank: 0)
        )
    }
}
