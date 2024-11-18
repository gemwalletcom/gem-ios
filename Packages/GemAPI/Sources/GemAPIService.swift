// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient
import Primitives

public protocol GemAPIConfigService: Sendable {
    func getConfig() async throws -> ConfigResponse
}

public protocol GemAPIFiatService: Sendable {
    func getBuyQuotes(asset: Asset, request: FiatBuyRequest) async throws -> [FiatQuote]
    func getSellQuotes(asset: Asset, request: FiatBuyRequest) async throws -> [FiatQuote]
}

public protocol GemAPIAssetsListService: Sendable {
    func getAssetsByDeviceId(deviceId: String, walletIndex: Int, fromTimestamp: Int) async throws -> [AssetId]
    func getBuyableFiatAssets() async throws -> FiatAssets
    func getSellableFiatAssets() async throws -> FiatAssets
    func getSwapAssets() async throws -> FiatAssets
}

public protocol GemAPIAssetsService: Sendable {
    func getAsset(assetId: AssetId) async throws -> AssetFull
    func getAssets(assetIds: [AssetId]) async throws -> [AssetFull]
    func getSearchAssets(query: String, chains: [Chain]) async throws -> [AssetFull]
}

public protocol GemAPINameService: Sendable {
    func getName(name: String, chain: String) async throws -> NameRecord
}

public protocol GemAPIChartService: Sendable {
    func getCharts(assetId: AssetId, currency: String, period: String) async throws -> Charts
}

public protocol GemAPIDeviceService: Sendable {
    func getDevice(deviceId: String) async throws -> Device
    func addDevice(device: Device) async throws -> Device
    func updateDevice(device: Device) async throws -> Device
    func deleteDevice(deviceId: String) async throws
}

public protocol GemAPISubscriptionService: Sendable {
    func getSubscriptions(deviceId: String) async throws -> [Subscription]
    func addSubscriptions(deviceId: String, subscriptions: [Subscription]) async throws
    func deleteSubscriptions(deviceId: String, subscriptions: [Subscription]) async throws
}

public protocol GemAPITransactionService: Sendable {
    func getTransactionsAll(deviceId: String, walletIndex: Int, fromTimestamp: Int) async throws -> [Primitives.Transaction]
    func getTransactionsForAsset(deviceId: String, walletIndex: Int, asset: AssetId, fromTimestamp: Int) async throws -> [Primitives.Transaction]
}

public protocol GemAPIPriceAlertService: Sendable {
    func getPriceAlerts(deviceId: String) async throws -> [PriceAlert]
    func addPriceAlerts(deviceId: String, priceAlerts: [PriceAlert]) async throws
    func deletePriceAlerts(deviceId: String, priceAlerts: [PriceAlert]) async throws
}

public struct GemAPIService {
    
    let provider: Provider<GemAPI>
    
    public static let shared = GemAPIService()
    public static let sharedProvider = Provider<GemAPI>()
    
    public init(
        provider: Provider<GemAPI> = Self.sharedProvider
    ) {
        self.provider = provider
    }
}

extension GemAPIService: GemAPIFiatService {
    public func getBuyQuotes(asset: Asset, request: FiatBuyRequest) async throws -> [FiatQuote] {
        return try await provider
            .request(.getFiatOnRampQuotes(asset, request))
            .map(as: FiatQuotes.self)
            .quotes
    }

    public func getSellQuotes(asset: Asset, request: FiatBuyRequest) async throws -> [FiatQuote] {
        return try await provider
            .request(.getFiatOffRampQuotes(asset, request))
            .map(as: FiatQuotes.self)
            .quotes
    }
}

extension GemAPIService: GemAPIConfigService {
    public func getConfig() async throws -> ConfigResponse {
        return try await provider
            .request(.getConfig)
            .map(as: ConfigResponse.self)
    }
}

extension GemAPIService: GemAPINameService {
    public func getName(name: String, chain: String) async throws -> NameRecord {
        return try await provider
            .request(.getNameRecord(name: name, chain: chain))
            .map(as: NameRecord.self)
    }
}

extension GemAPIService: GemAPIChartService {
    public func getCharts(assetId: AssetId, currency: String, period: String) async throws -> Charts {
        return try await provider
            .request(.getCharts(assetId, currency: currency, period: period))
            .map(as: Charts.self)
    }
}

extension GemAPIService: GemAPIDeviceService {
    public func getDevice(deviceId: String) async throws -> Device {
        return try await provider
            .request(.getDevice(deviceId: deviceId))
            .map(as: Device.self)
    }
    
    public func addDevice(device: Primitives.Device) async throws -> Device {
        return try await provider
            .request(.addDevice(device: device))
            .map(as: Device.self)
    }
    
    public func updateDevice(device: Primitives.Device) async throws -> Device {
        return try await provider
            .request(.updateDevice(device: device))
            .map(as: Device.self)
    }
    
    public func deleteDevice(deviceId: String) async throws {
        let _ = try await provider
            .request(.deleteDevice(deviceId: deviceId))
    }
}

extension GemAPIService: GemAPISubscriptionService {
    public func getSubscriptions(deviceId: String) async throws -> [Subscription] {
        return try await provider
            .request(.getSubscriptions(deviceId: deviceId))
            .map(as: [Subscription].self)
    }
    
    public func addSubscriptions(deviceId: String, subscriptions: [Subscription]) async throws {
        let _ = try await provider
            .request(.addSubscriptions(deviceId: deviceId, subscriptions: subscriptions))
            .map(as: Int.self)
    }
    
    public func deleteSubscriptions(deviceId: String, subscriptions: [Subscription]) async throws {
        let _ = try await provider
            .request(.deleteSubscriptions(deviceId: deviceId, subscriptions: subscriptions))
            .map(as: Int.self)
    }
}

extension GemAPIService: GemAPITransactionService {
    public func getTransactionsForAsset(deviceId: String, walletIndex: Int, asset: Primitives.AssetId, fromTimestamp: Int) async throws -> [Primitives.Transaction] {
        let options = TransactionsFetchOption(wallet_index: walletIndex.asInt32, asset_id: asset.identifier, from_timestamp: fromTimestamp.asUInt32)
        return try await provider
            .request(.getTransactions(deviceId: deviceId, options: options))
            .map(as: [Primitives.Transaction].self)
    }
    
    public func getTransactionsAll(deviceId: String, walletIndex: Int, fromTimestamp: Int) async throws -> [Primitives.Transaction] {
        let options = TransactionsFetchOption(wallet_index: walletIndex.asInt32, asset_id: .none, from_timestamp: fromTimestamp.asUInt32)
        return try await provider
            .request(.getTransactions(deviceId: deviceId, options: options))
            .map(as: [Primitives.Transaction].self)
    }
}

extension GemAPIService: GemAPIAssetsListService {
    public func getAssetsByDeviceId(deviceId: String, walletIndex: Int, fromTimestamp: Int) async throws -> [Primitives.AssetId] {
        try await provider
            .request(.getAssetsList(deviceId: deviceId, walletIndex: walletIndex, fromTimestamp: fromTimestamp))
            .map(as: [String].self)
            .compactMap { try? AssetId(id: $0) }
    }

    public func getBuyableFiatAssets() async throws -> FiatAssets {
        try await provider
            .request(.getFiatOnRampAssets)
            .map(as: FiatAssets.self)
    }

    public func getSellableFiatAssets() async throws -> FiatAssets {
        try await provider
            .request(.getFiatOffRampAssets)
            .map(as: FiatAssets.self)
    }

    public func getFiatAssets(buy: Bool) async throws -> FiatAssets {
        try await provider
            .request(buy ? .getFiatOnRampAssets : .getFiatOffRampAssets)
            .map(as: FiatAssets.self)
    }
    
    public func getSwapAssets() async throws -> FiatAssets {
        try await provider
            .request(.getSwapAssets)
            .map(as: FiatAssets.self)
    }
}

extension GemAPIService: GemAPIAssetsService {
    public func getAsset(assetId: AssetId) async throws -> AssetFull {
        return try await provider
            .request(.getAsset(assetId))
            .map(as: AssetFull.self)
    }
    
    public func getAssets(assetIds: [AssetId]) async throws -> [AssetFull] {
        return try await provider
            .request(.getAssets(assetIds))
            .map(as: [AssetFull].self)
    }
    
    public func getSearchAssets(query: String, chains: [Chain]) async throws -> [AssetFull] {
        try await provider
            .request(.getSearchAssets(query: query, chains: chains))
            .map(as: [AssetFull].self)
    }
}

extension GemAPIService: GemAPIPriceAlertService {
    public func getPriceAlerts(deviceId: String) async throws -> [PriceAlert] {
        return try await provider
            .request(.getPriceAlerts(deviceId: deviceId))
            .map(as: [PriceAlert].self)
    }

    public func addPriceAlerts(deviceId: String, priceAlerts: [PriceAlert]) async throws {
        let _ = try await provider
            .request(.addPriceAlerts(deviceId: deviceId, priceAlerts: priceAlerts))
            .map(as: Int.self)
    }

    public func deletePriceAlerts(deviceId: String, priceAlerts: [PriceAlert]) async throws {
        let _ = try await provider
            .request(.deletePriceAlerts(deviceId: deviceId, priceAlerts: priceAlerts))
            .map(as: Int.self)
    }
}
