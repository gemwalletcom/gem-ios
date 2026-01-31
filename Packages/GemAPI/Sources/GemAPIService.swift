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
    func migrateDevice(request: MigrateDeviceIdRequest) async throws -> Device
}

public protocol GemAPISubscriptionService: Sendable {
    func getSubscriptions(deviceId: String) async throws -> [WalletSubscriptionChains]
    func addSubscriptions(deviceId: String, subscriptions: [WalletSubscription]) async throws
    func deleteSubscriptions(deviceId: String, walletIds: [String]) async throws
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
    func reportNft(deviceId: String, report: ReportNft) async throws
}

public protocol GemAPIScanService: Sendable {
    func getScanTransaction(deviceId: String, payload: ScanTransactionPayload) async throws -> ScanTransaction
}

public protocol GemAPIMarketService: Sendable {
    func getMarkets() async throws -> Markets
}

public protocol GemAPISupportService: Sendable {
    func addSupportDevice(deviceId: String, supportDeviceId: String) async throws -> SupportDevice
}

public protocol GemAPIAuthService: Sendable {
    func getAuthNonce(deviceId: String) async throws -> AuthNonce
}

public protocol GemAPIRewardsService: Sendable {
    func getRewards(deviceId: String, walletId: String) async throws -> Rewards
    func getRewardsEvents(deviceId: String, walletId: String) async throws -> [RewardEvent]
    func createReferral(deviceId: String, walletId: String, request: AuthenticatedRequest<ReferralCode>) async throws -> Rewards
    func useReferralCode(deviceId: String, walletId: String, request: AuthenticatedRequest<ReferralCode>) async throws
    func getRedemptionOption(deviceId: String, code: String) async throws -> RewardRedemptionOption
    func redeem(deviceId: String, walletId: String, request: AuthenticatedRequest<RedemptionRequest>) async throws -> RedemptionResult
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
    let deviceProvider: Provider<GemDeviceAPI>

    public static let shared = GemAPIService()
    public static let sharedProvider = Provider<GemAPI>()
    public static let sharedDeviceProvider = Provider<GemDeviceAPI>()

    public init(
        provider: Provider<GemAPI> = Self.sharedProvider,
        deviceProvider: Provider<GemDeviceAPI> = Self.sharedDeviceProvider
    ) {
        self.provider = provider
        self.deviceProvider = deviceProvider
    }

    public static func createDeviceProvider(devicePrivateKey: Data) throws -> Provider<GemDeviceAPI> {
        let signer = try DeviceRequestSigner(privateKey: devicePrivateKey)
        let options = ProviderOptions(
            baseUrl: nil,
            requestInterceptor: { request in
                try signer.sign(request: &request)
            }
        )
        return Provider<GemDeviceAPI>(options: options)
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
        try await deviceProvider
            .request(.getDevice(deviceId: deviceId))
            .mapOrCatch(as: Device?.self, codes: [404], result: nil)
    }

    public func addDevice(device: Primitives.Device) async throws -> Device {
        try await deviceProvider
            .request(.addDevice(device: device))
            .mapResponse(as: Device.self)
    }

    public func updateDevice(device: Primitives.Device) async throws -> Device {
        try await deviceProvider
            .request(.updateDevice(device: device))
            .mapResponse(as: Device.self)
    }

    public func isDeviceRegistered(deviceId: String) async throws -> Bool {
        try await deviceProvider
            .request(.isDeviceRegistered(deviceId: deviceId))
            .mapResponse(as: Bool.self)
    }

    public func migrateDevice(request: MigrateDeviceIdRequest) async throws -> Device {
        try await deviceProvider
            .request(.migrateDevice(request: request))
            .mapResponse(as: Device.self)
    }
}

extension GemAPIService: GemAPISubscriptionService {
    public func getSubscriptions(deviceId: String) async throws -> [WalletSubscriptionChains] {
        try await deviceProvider
            .request(.getSubscriptions(deviceId: deviceId))
            .mapResponse(as: [WalletSubscriptionChains].self)
    }

    public func addSubscriptions(deviceId: String, subscriptions: [WalletSubscription]) async throws {
        try await deviceProvider
            .request(.addSubscriptions(deviceId: deviceId, subscriptions: subscriptions))
            .mapResponse(as: Int.self)
    }

    public func deleteSubscriptions(deviceId: String, walletIds: [String]) async throws {
        try await deviceProvider
            .request(.deleteSubscriptions(deviceId: deviceId, walletIds: walletIds))
            .mapResponse(as: Int.self)
    }
}

extension GemAPIService: GemAPITransactionService {
    public func getDeviceTransactionsForAsset(deviceId: String, walletId: String, asset: Primitives.AssetId, fromTimestamp: Int) async throws -> TransactionsResponse {
        try await deviceProvider
            .request(.getTransactions(deviceId: deviceId, walletId: walletId, assetId: asset.identifier, fromTimestamp: fromTimestamp))
            .mapResponse(as: TransactionsResponse.self)
    }

    public func getDeviceTransactions(deviceId: String, walletId: String, fromTimestamp: Int) async throws -> TransactionsResponse {
        try await deviceProvider
            .request(.getTransactions(deviceId: deviceId, walletId: walletId, assetId: nil, fromTimestamp: fromTimestamp))
            .mapResponse(as: TransactionsResponse.self)
    }
}

extension GemAPIService: GemAPIAssetsListService {
    public func getDeviceAssets(deviceId: String, walletId: String, fromTimestamp: Int) async throws -> [Primitives.AssetId] {
        try await deviceProvider
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
        try await deviceProvider
            .request(.getPriceAlerts(deviceId: deviceId, assetId: assetId))
            .mapResponse(as: [PriceAlert].self)
    }

    public func addPriceAlerts(deviceId: String, priceAlerts: [PriceAlert]) async throws {
        let _ = try await deviceProvider
            .request(.addPriceAlerts(deviceId: deviceId, priceAlerts: priceAlerts))
            .mapResponse(as: Int.self)
    }

    public func deletePriceAlerts(deviceId: String, priceAlerts: [PriceAlert]) async throws {
        let _ = try await deviceProvider
            .request(.deletePriceAlerts(deviceId: deviceId, priceAlerts: priceAlerts))
            .mapResponse(as: Int.self)
    }
}

extension GemAPIService: GemAPINFTService {
    public func getDeviceNFTAssets(deviceId: String, walletId: String) async throws -> [NFTData] {
        try await deviceProvider
            .request(.getDeviceNFTAssets(deviceId: deviceId, walletId: walletId))
            .mapResponse(as: [NFTData].self)
    }

    public func reportNft(deviceId: String, report: ReportNft) async throws {
        _ = try await deviceProvider
            .request(.reportNft(deviceId: deviceId, report: report))
    }
}

extension GemAPIService: GemAPIScanService {
    public func getScanTransaction(deviceId: String, payload: ScanTransactionPayload) async throws -> ScanTransaction {
        try await deviceProvider
            .request(.scanTransaction(deviceId: deviceId, payload: payload))
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
    public func addSupportDevice(deviceId: String, supportDeviceId: String) async throws -> SupportDevice {
        try await deviceProvider
            .request(.addSupportDevice(deviceId: deviceId, supportDeviceId: supportDeviceId))
            .mapResponse(as: SupportDevice.self)
    }
}

extension GemAPIService: GemAPIAuthService {
    public func getAuthNonce(deviceId: String) async throws -> AuthNonce {
        try await deviceProvider
            .request(.getAuthNonce(deviceId: deviceId))
            .mapResponse(as: AuthNonce.self)
    }
}

extension GemAPIService: GemAPIRewardsService {
    public func getRewards(deviceId: String, walletId: String) async throws -> Rewards {
        try await deviceProvider
            .request(.getDeviceRewards(deviceId: deviceId, walletId: walletId))
            .mapResponse(as: Rewards.self)
    }

    public func getRewardsEvents(deviceId: String, walletId: String) async throws -> [RewardEvent] {
        try await deviceProvider
            .request(.getDeviceRewardsEvents(deviceId: deviceId, walletId: walletId))
            .mapResponse(as: [RewardEvent].self)
    }

    public func createReferral(deviceId: String, walletId: String, request: AuthenticatedRequest<ReferralCode>) async throws -> Rewards {
        try await deviceProvider
            .request(.createDeviceReferral(deviceId: deviceId, walletId: walletId, request: request))
            .mapResponse(as: Rewards.self)
    }

    public func useReferralCode(deviceId: String, walletId: String, request: AuthenticatedRequest<ReferralCode>) async throws {
        _ = try await deviceProvider
            .request(.useDeviceReferralCode(deviceId: deviceId, walletId: walletId, request: request))
            .mapResponse(as: [RewardEvent].self)
    }

    public func getRedemptionOption(deviceId: String, code: String) async throws -> RewardRedemptionOption {
        try await deviceProvider
            .request(.getDeviceRedemptionOption(deviceId: deviceId, code: code))
            .mapResponse(as: RewardRedemptionOption.self)
    }

    public func redeem(deviceId: String, walletId: String, request: AuthenticatedRequest<RedemptionRequest>) async throws -> RedemptionResult {
        try await deviceProvider
            .request(.redeemDeviceRewards(deviceId: deviceId, walletId: walletId, request: request))
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
        try await deviceProvider
            .request(.getNotifications(deviceId: deviceId, fromTimestamp: fromTimestamp))
            .mapResponse(as: [Primitives.InAppNotification].self)
    }

    public func markNotificationsRead(deviceId: String) async throws {
        _ = try await deviceProvider
            .request(.markNotificationsRead(deviceId: deviceId))
    }
}

extension SwiftHTTPClient.Response {
    @discardableResult
    public func mapResponse<T: Decodable>(as type: T.Type) throws -> T {
        try self.mapOrError(as: type, asError: ResponseError.self)
    }
}
