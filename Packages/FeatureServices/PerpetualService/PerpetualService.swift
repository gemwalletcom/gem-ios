// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.GemPerpetualBalance
import struct Gemstone.GemPerpetualPosition
import Primitives
import Store
import Formatters

public struct PerpetualService: PerpetualServiceable {
    
    private let store: PerpetualStore
    private let assetStore: AssetStore
    private let priceStore: PriceStore
    private let balanceStore: BalanceStore
    private let provider: PerpetualProvidable
    
    public init(
        store: PerpetualStore,
        assetStore: AssetStore,
        priceStore: PriceStore,
        balanceStore: BalanceStore,
        provider: PerpetualProvidable
    ) {
        self.store = store
        self.assetStore = assetStore
        self.priceStore = priceStore
        self.balanceStore = balanceStore
        self.provider = provider
    }
    
    public func getPositions(walletId: WalletId) async throws -> [PerpetualPosition] {
        try store.getPositions(walletId: walletId)
    }
    
    public func getMarkets() async throws -> [Perpetual] {
        try store.getPerpetuals()
    }

    public func updateMarkets() async throws {
        let perpetualsData = try await provider.getPerpetualsData()
        let perpetuals = perpetualsData.map { $0.perpetual }
        let assets = perpetualsData.map { createPerpetualAssetBasic(from: $0.asset) }

        try assetStore.add(assets: assets)
        try store.upsertPerpetuals(perpetuals)
        // setup prices
        try priceStore.updatePrice(price: AssetPrice(
            assetId: Asset.hypercoreUSDC().id,
            price: 1,
            priceChangePercentage24h: 0,
            updatedAt: .now
        ), currency: Currency.usd.rawValue)
    }

    public func updateMarket(symbol: String) async throws {
        try await updateMarkets()
    }

    public func candlesticks(symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick] {
        return try await provider.getCandlesticks(symbol: symbol, period: period)
    }

    public func portfolio(address: String) async throws -> PerpetualPortfolio {
        try await provider.getPortfolio(address: address)
    }

    public func setPinned(_ isPinned: Bool, perpetualId: String) throws {
        try store.setPinned(for: [perpetualId], value: isPinned)
    }

    public func clear() throws {
        try store.clear()
    }

    // MARK: - Private

    private func syncProviderBalances(walletId: WalletId, balance: PerpetualBalance) throws {
        let usd = Asset.hypercoreUSDC()
        let formatter = ValueFormatter.full
        try balanceStore.addMissingBalances(walletId: walletId, assetIds: [usd.id], isEnabled: false)

        let perpetuals = try store.getPerpetuals().map(\.assetId)
        try balanceStore.addMissingBalances(walletId: walletId, assetIds: perpetuals, isEnabled: false)

        try balanceStore.updateBalances(
            [
             UpdateBalance(
                assetId: usd.id,
                type: .perpetual(UpdatePerpetualBalance(
                    available: UpdateBalanceValue(
                        value: try formatter.inputNumber(from: balance.available.description, decimals: 6).description,
                        amount: balance.available
                    ),
                    reserved: UpdateBalanceValue(
                        value: try formatter.inputNumber(from: balance.reserved.description, decimals: 6).description,
                        amount: balance.reserved
                    ),
                    withdrawable: UpdateBalanceValue(
                        value: try formatter.inputNumber(from: balance.withdrawable.description, decimals: 6).description,
                        amount: balance.withdrawable
                    )
                )),
                updatedAt: .now,
                isActive: true
             ),
            ],
            for: walletId
        )
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
                stakingApr: nil,
                isEarnable: false,
                earnApr: nil,
                hasImage: false
            ),
            score: AssetScore(rank: 0),
            price: nil
        )
    }
}

// MARK: - HyperliquidPerpetualServiceable

extension PerpetualService: HyperliquidPerpetualServiceable {
    public func getHypercorePositions(walletId: WalletId) throws -> [GemPerpetualPosition] {
        try store.getPositions(walletId: walletId, provider: .hypercore).map { $0.map() }
    }

    public func updateBalance(walletId: WalletId, balance: GemPerpetualBalance) throws {
        try syncProviderBalances(walletId: walletId, balance: balance.map())
    }

    public func diffPositions(deleteIds: [String], positions: [GemPerpetualPosition], walletId: WalletId) throws {
        try store.diffPositions(deleteIds: deleteIds, positions: positions.map { try $0.map() }, walletId: walletId)
    }
}
