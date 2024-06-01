// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient
import Primitives

public protocol GemAPIConfigService {
    func getConfig() async throws -> ConfigResponse
}

public protocol GemAPINodesService {
    func getNodes() async throws -> NodesResponse
}

public protocol GemAPIFiatService {
    func getQuotes(asset: Asset, request: FiatBuyRequest) async throws -> [FiatQuote]
}

public protocol GemAPIAssetsListService {
    func getAssetsByDeviceId(deviceId: String, walletIndex: Int, fromTimestamp: Int) async throws -> [AssetId]
    func getFiatAssets() async throws -> FiatAssets
    func getSwapAssets() async throws -> FiatAssets
}

public protocol GemAPIAssetsService {
    func getAsset(assetId: AssetId) async throws -> AssetFull
    func getAssets(assetIds: [AssetId]) async throws -> [AssetFull]
    func getSearchAssets(query: String, chains: [Chain]) async throws -> [AssetFull]
}

public protocol GemAPINameService {
    func getName(name: String, chain: String) async throws -> NameRecord
}

public protocol GemAPIChartService {
    func getCharts(assetId: AssetId, currency: String, period: String) async throws -> Charts
}

public protocol GemAPIDeviceService {
    func getDevice(deviceId: String) async throws -> Device
    func addDevice(device: Device) async throws -> Device
    func updateDevice(device: Device) async throws -> Device
    func deleteDevice(deviceId: String) async throws
}

public protocol GemAPISubscriptionService {
    func getSubscriptions(deviceId: String) async throws -> [Subscription]
    func addSubscriptions(deviceId: String, subscriptions: [Subscription]) async throws
    func deleteSubscriptions(deviceId: String, subscriptions: [Subscription]) async throws
}

public protocol GemAPITransactionService {
    func getTransactionsAll(deviceId: String, walletIndex: Int, fromTimestamp: Int) async throws -> [Primitives.Transaction]
    func getTransactionsForAsset(deviceId: String, walletIndex: Int, asset: AssetId, fromTimestamp: Int) async throws -> [Primitives.Transaction]
}

public protocol GemAPISwapService {
    func getSwap(request: SwapQuoteRequest) async throws -> SwapQuoteResult
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
    public func getQuotes(asset: Asset, request: FiatBuyRequest) async throws -> [FiatQuote] {
        return try await provider
            .request(.getFiatOnRampQuotes(asset, request))
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

extension GemAPIService: GemAPINodesService {
    public func getNodes() async throws -> NodesResponse {
        return try await provider
            .request(.getNodes)
            .map(as: NodesResponse.self)
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

extension GemAPIService: GemAPISwapService {
    public func getSwap(request: SwapQuoteRequest) async throws -> SwapQuoteResult {
        return try await provider
            .request(.getSwap(request))
            .map(as: SwapQuoteResult.self)
    }
}

extension GemAPIService: GemAPIAssetsListService {
    public func getAssetsByDeviceId(deviceId: String, walletIndex: Int, fromTimestamp: Int) async throws -> [Primitives.AssetId] {
        try await provider
            .request(.getAssetsList(deviceId: deviceId, walletIndex: walletIndex, fromTimestamp: fromTimestamp))
            .map(as: [String].self)
            .compactMap { AssetId(id: $0) }
    }
    
    public func getFiatAssets() async throws -> FiatAssets {
        try await provider
            .request(.getFiatOnRampAssets)
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
