// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient
import Primitives

public protocol GemAPIConfigService: Sendable {
    func getConfig() async throws -> ConfigResponse
}

public protocol GemAPIFiatService: Sendable {
    func getQuotes(type: FiatQuoteType, assetId: AssetId, request: FiatQuoteRequest) async throws -> [FiatQuote]
    func getQuoteUrl(request: FiatQuoteUrlRequest) async throws -> FiatQuoteUrl
}

public protocol GemAPIPricesService: Sendable {
    func getPrices(currency: String?, assetIds: [AssetId]) async throws -> [AssetPrice]
}

public protocol GemAPIAssetsListService: Sendable {
    func getDeviceAssets(deviceId: String, walletId: String, fromTimestamp: Int) async throws -> [AssetId]
    func getBuyableFiatAssets() async throws -> FiatAssets
    func getSellableFiatAssets() async throws -> FiatAssets
    func getSwapAssets() async throws -> FiatAssets
}

public protocol GemAPIAssetsService: Sendable {
    func getAsset(assetId: AssetId) async throws -> AssetFull
    func getAssets(assetIds: [AssetId]) async throws -> [AssetBasic]
    func getSearchAssets(query: String, chains: [Chain], tags: [AssetTag]) async throws -> [AssetBasic]
}

public protocol GemAPINameService: Sendable {
    func getName(name: String, chain: String) async throws -> NameRecord
}

public protocol GemAPIChartService: Sendable {
    func getCharts(assetId: AssetId, period: String) async throws -> Charts
}

public protocol GemAPIDeviceService: Sendable {
    func getDevice(deviceId: String) async throws -> Device?
    func addDevice(device: Device) async throws -> Device
    func updateDevice(device: Device) async throws -> Device
    func isDeviceRegistered(deviceId: String) async throws -> Bool
}

public protocol GemAPISubscriptionService: Sendable {
    func getSubscriptions(deviceId: String) async throws -> [Subscription]
    func addSubscriptions(deviceId: String, subscriptions: [Subscription]) async throws
    func deleteSubscriptions(deviceId: String, subscriptions: [Subscription]) async throws

    func getSubscriptionsV2(deviceId: String) async throws -> [WalletSubscriptionChains]
    func addSubscriptionsV2(deviceId: String, subscriptions: [WalletSubscription]) async throws
    func deleteSubscriptionsV2(deviceId: String, subscriptions: [WalletSubscription]) async throws
}

public protocol GemAPITransactionService: Sendable {
    func getDeviceTransactions(deviceId: String, walletId: String, fromTimestamp: Int) async throws -> TransactionsResponse
    func getDeviceTransactionsForAsset(deviceId: String, walletId: String, asset: AssetId, fromTimestamp: Int) async throws -> TransactionsResponse
}

public protocol GemAPIPriceAlertService: Sendable {
    func getPriceAlerts(deviceId: String, assetId: String?) async throws -> [PriceAlert]
    func addPriceAlerts(deviceId: String, priceAlerts: [PriceAlert]) async throws
    func deletePriceAlerts(deviceId: String, priceAlerts: [PriceAlert]) async throws
}

public protocol GemAPINFTService: Sendable {
    func getDeviceNFTAssets(deviceId: String, walletId: String) async throws -> [NFTData]
    func reportNft(_ report: ReportNft) async throws
}

public protocol GemAPIScanService: Sendable {
    func getScanTransaction(payload: ScanTransactionPayload) async throws -> ScanTransaction
}

public protocol GemAPIMarketService: Sendable {
    func getMarkets() async throws -> Markets
}

public protocol GemAPISupportService: Sendable {
    func addSupportDevice(_ supportDevice: NewSupportDevice) async throws -> SupportDevice
}

public protocol GemAPIAuthService: Sendable {
    func getAuthNonce(deviceId: String) async throws -> AuthNonce
}

public protocol GemAPIRewardsService: Sendable {
    func getRewards(walletId: String) async throws -> Rewards
    func createReferral(request: AuthenticatedRequest<ReferralCode>) async throws -> Rewards
    func useReferralCode(request: AuthenticatedRequest<ReferralCode>) async throws
    func getRedemptionOption(code: String) async throws -> RewardRedemptionOption
    func redeem(walletId: String, request: AuthenticatedRequest<RedemptionRequest>) async throws -> RedemptionResult
}

public protocol GemAPISearchService: Sendable {
    func search(query: String, chains: [Chain], tags: [AssetTag]) async throws -> SearchResponse
}

public protocol GemAPINotificationService: Sendable {
    func getNotifications(deviceId: String, fromTimestamp: Int) async throws -> [Primitives.InAppNotification]
    func markNotificationsRead(deviceId: String) async throws
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
    public func getQuotes(type: FiatQuoteType, assetId: AssetId, request: FiatQuoteRequest) async throws -> [FiatQuote] {
        try await provider
            .request(.getFiatQuotes(type, assetId, request))
            .mapResponse(as: FiatQuotes.self)
            .quotes
    }

    public func getQuoteUrl(request: FiatQuoteUrlRequest) async throws -> FiatQuoteUrl {
        try await provider
            .request(.getFiatQuoteUrl(request))
            .mapResponse(as: FiatQuoteUrl.self)
    }
}

extension GemAPIService: GemAPIConfigService {
    public func getConfig() async throws -> ConfigResponse {
        try await provider
            .request(.getConfig)
            .mapResponse(as: ConfigResponse.self)
    }
}

extension GemAPIService: GemAPINameService {
    public func getName(name: String, chain: String) async throws -> NameRecord {
        try await provider
            .request(.getNameRecord(name: name, chain: chain))
            .mapResponse(as: NameRecord.self)
    }
}

extension GemAPIService: GemAPIChartService {
    public func getCharts(assetId: AssetId, period: String) async throws -> Charts {
        try await provider
            .request(.getCharts(assetId, period: period))
            .mapResponse(as: Charts.self)
    }
}

extension GemAPIService: GemAPIDeviceService {
    public func getDevice(deviceId: String) async throws -> Device? {
        try await provider
            .request(.getDevice(deviceId: deviceId))
            .mapOrCatch(as: Device?.self, codes: [404], result: nil)
    }
    
    public func addDevice(device: Primitives.Device) async throws -> Device {
        try await provider
            .request(.addDevice(device: device))
            .mapResponse(as: Device.self)
    }

    public func updateDevice(device: Primitives.Device) async throws -> Device {
        try await provider
            .request(.updateDevice(device: device))
            .mapResponse(as: Device.self)
    }

    public func isDeviceRegistered(deviceId: String) async throws -> Bool {
        try await provider
            .request(.isDeviceRegistered(deviceId: deviceId))
            .mapResponse(as: Bool.self)
    }
}

extension GemAPIService: GemAPISubscriptionService {
    public func getSubscriptions(deviceId: String) async throws -> [Subscription] {
        try await provider
            .request(.getSubscriptions(deviceId: deviceId))
            .mapResponse(as: [Subscription].self)
    }

    public func addSubscriptions(deviceId: String, subscriptions: [Subscription]) async throws {
        try await provider
            .request(.addSubscriptions(deviceId: deviceId, subscriptions: subscriptions))
            .mapResponse(as: Int.self)
    }

    public func deleteSubscriptions(deviceId: String, subscriptions: [Subscription]) async throws {
        try await provider
            .request(.deleteSubscriptions(deviceId: deviceId, subscriptions: subscriptions))
            .mapResponse(as: Int.self)
    }

    public func getSubscriptionsV2(deviceId: String) async throws -> [WalletSubscriptionChains] {
        try await provider
            .request(.getSubscriptionsV2(deviceId: deviceId))
            .mapResponse(as: [WalletSubscriptionChains].self)
    }

    public func addSubscriptionsV2(deviceId: String, subscriptions: [WalletSubscription]) async throws {
        try await provider
            .request(.addSubscriptionsV2(deviceId: deviceId, subscriptions: subscriptions))
            .mapResponse(as: Int.self)
    }

    public func deleteSubscriptionsV2(deviceId: String, subscriptions: [WalletSubscription]) async throws {
        try await provider
            .request(.deleteSubscriptionsV2(deviceId: deviceId, subscriptions: subscriptions))
            .mapResponse(as: Int.self)
    }
}

extension GemAPIService: GemAPITransactionService {
    public func getDeviceTransactionsForAsset(deviceId: String, walletId: String, asset: Primitives.AssetId, fromTimestamp: Int) async throws -> TransactionsResponse {
        try await provider
            .request(.getTransactions(deviceId: deviceId, walletId: walletId, assetId: asset.identifier, fromTimestamp: fromTimestamp))
            .mapResponse(as: TransactionsResponse.self)
    }

    public func getDeviceTransactions(deviceId: String, walletId: String, fromTimestamp: Int) async throws -> TransactionsResponse {
        try await provider
            .request(.getTransactions(deviceId: deviceId, walletId: walletId, assetId: nil, fromTimestamp: fromTimestamp))
            .mapResponse(as: TransactionsResponse.self)
    }
}

extension GemAPIService: GemAPIAssetsListService {
    public func getDeviceAssets(deviceId: String, walletId: String, fromTimestamp: Int) async throws -> [Primitives.AssetId] {
        try await provider
            .request(.getAssetsList(deviceId: deviceId, walletId: walletId, fromTimestamp: fromTimestamp))
            .mapResponse(as: [String].self)
            .compactMap { try? AssetId(id: $0) }
    }

    public func getBuyableFiatAssets() async throws -> FiatAssets {
        try await provider
            .request(.getFiatAssets(.buy))
            .mapResponse(as: FiatAssets.self)
    }

    public func getSellableFiatAssets() async throws -> FiatAssets {
        try await provider
            .request(.getFiatAssets(.sell))
            .mapResponse(as: FiatAssets.self)
    }

    public func getSwapAssets() async throws -> FiatAssets {
        try await provider
            .request(.getSwapAssets)
            .mapResponse(as: FiatAssets.self)
    }
}

extension GemAPIService: GemAPIAssetsService {
    public func getAsset(assetId: AssetId) async throws -> AssetFull {
        try await provider
            .request(.getAsset(assetId))
            .mapResponse(as: AssetFull.self)
    }

    public func getAssets(assetIds: [AssetId]) async throws -> [AssetBasic] {
        try await provider
            .request(.getAssets(assetIds))
            .mapResponse(as: [AssetBasic].self)
    }

    public func getSearchAssets(query: String, chains: [Chain], tags: [AssetTag]) async throws -> [AssetBasic] {
        try await provider
            .request(.getSearchAssets(query: query, chains: chains, tags: tags))
            .mapResponse(as: [AssetBasic].self)
    }
}

extension GemAPIService: GemAPIPriceAlertService {
    public func getPriceAlerts(deviceId: String, assetId: String?) async throws -> [PriceAlert] {
        try await provider
            .request(.getPriceAlerts(deviceId: deviceId, assetId: assetId))
            .mapResponse(as: [PriceAlert].self)
    }

    public func addPriceAlerts(deviceId: String, priceAlerts: [PriceAlert]) async throws {
        let _ = try await provider
            .request(.addPriceAlerts(deviceId: deviceId, priceAlerts: priceAlerts))
            .mapResponse(as: Int.self)
    }

    public func deletePriceAlerts(deviceId: String, priceAlerts: [PriceAlert]) async throws {
        let _ = try await provider
            .request(.deletePriceAlerts(deviceId: deviceId, priceAlerts: priceAlerts))
            .mapResponse(as: Int.self)
    }
}

extension GemAPIService: GemAPINFTService {
    public func getDeviceNFTAssets(deviceId: String, walletId: String) async throws -> [NFTData] {
        try await provider
            .request(.getDeviceNFTAssets(deviceId: deviceId, walletId: walletId))
            .mapResponse(as: [NFTData].self)
    }

    public func reportNft(_ report: ReportNft) async throws {
        _ = try await provider
            .request(.reportNft(report))
    }
}

extension GemAPIService: GemAPIScanService {
    public func getScanTransaction(payload: ScanTransactionPayload) async throws -> ScanTransaction {
        try await provider
            .request(.scanTransaction(payload: payload))
            .mapResponse(as: ScanTransaction.self)
    }
}

extension GemAPIService: GemAPIMarketService {
    public func getMarkets() async throws -> Markets {
        try await provider
            .request(.markets)
            .mapResponse(as: Markets.self)
    }
}

extension GemAPIService: GemAPIPricesService {
    public func getPrices(currency: String?, assetIds: [AssetId]) async throws -> [AssetPrice] {
        try await provider
            .request(.getPrices(AssetPricesRequest(currency: currency, assetIds: assetIds)))
            .mapResponse(as: AssetPrices.self).prices
    }
}

extension GemAPIService: GemAPISupportService {
    @discardableResult
    public func addSupportDevice(_ supportDevice: NewSupportDevice) async throws -> SupportDevice {
        try await provider
            .request(.addSupportDevice(supportDevice))
            .mapResponse(as: SupportDevice.self)
    }
}

extension GemAPIService: GemAPIAuthService {
    public func getAuthNonce(deviceId: String) async throws -> AuthNonce {
        try await provider
            .request(.getAuthNonce(deviceId: deviceId))
            .mapResponse(as: AuthNonce.self)
    }
}

extension GemAPIService: GemAPIRewardsService {
    public func getRewards(walletId: String) async throws -> Rewards {
        try await provider
            .request(.getRewards(walletId: walletId))
            .mapResponse(as: Rewards.self)
    }

    public func createReferral(request: AuthenticatedRequest<ReferralCode>) async throws -> Rewards {
        try await provider
            .request(.createReferral(request))
            .mapResponse(as: Rewards.self)
    }

    public func useReferralCode(request: AuthenticatedRequest<ReferralCode>) async throws {
        _ = try await provider
            .request(.useReferralCode(request))
            .mapResponse(as: [RewardEvent].self)
    }

    public func getRedemptionOption(code: String) async throws -> RewardRedemptionOption {
        try await provider
            .request(.getRedemptionOption(code: code))
            .mapResponse(as: RewardRedemptionOption.self)
    }

    public func redeem(walletId: String, request: AuthenticatedRequest<RedemptionRequest>) async throws -> RedemptionResult {
        try await provider
            .request(.redeem(walletId: walletId, request: request))
            .mapResponse(as: RedemptionResult.self)
    }
}

extension GemAPIService: GemAPISearchService {
    public func search(query: String, chains: [Chain], tags: [AssetTag]) async throws -> SearchResponse {
        try await provider
            .request(.getSearch(query: query, chains: chains, tags: tags))
            .mapResponse(as: SearchResponse.self)
    }
}

extension GemAPIService: GemAPINotificationService {
    public func getNotifications(deviceId: String, fromTimestamp: Int) async throws -> [Primitives.InAppNotification] {
        try await provider
            .request(.getNotifications(deviceId: deviceId, fromTimestamp: fromTimestamp))
            .mapResponse(as: [Primitives.InAppNotification].self)
    }

    public func markNotificationsRead(deviceId: String) async throws {
        _ = try await provider
            .request(.markNotificationsRead(deviceId: deviceId))
    }
}

extension SwiftHTTPClient.Response {
    @discardableResult
    public func mapResponse<T: Decodable>(as type: T.Type) throws -> T {
        try self.mapOrError(as: type, asError: ResponseError.self)
    }
}
