// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient
import Primitives

public enum GemAPI: TargetType {
    case getFiatAssets(FiatQuoteType)
    case getFiatQuotes(FiatQuoteType, AssetId, FiatQuoteRequest)
    case getFiatQuoteUrl(FiatQuoteUrlRequest)
    case getSwapAssets
    case getConfig
    case getNameRecord(name: String, chain: String)
    case getPrices(AssetPricesRequest)
    case getCharts(AssetId, period: String)

    case getDevice(deviceId: String)
    case addDevice(device: Device)
    case updateDevice(device: Device)
    case deleteDevice(deviceId: String)

    case getSubscriptions(deviceId: String)
    case addSubscriptions(deviceId: String, subscriptions: [WalletSubscription])
    case deleteSubscriptions(deviceId: String, subscriptions: [WalletSubscription])

    case getPriceAlerts(deviceId: String, assetId: String?)
    case addPriceAlerts(deviceId: String, priceAlerts: [PriceAlert])
    case deletePriceAlerts(deviceId: String, priceAlerts: [PriceAlert])

    case getTransactions(deviceId: String, walletId: String, assetId: String?, fromTimestamp: Int)

    case getAsset(AssetId)
    case getAssets([AssetId])
    case getSearchAssets(query: String, chains: [Chain], tags: [AssetTag])
    case getSearch(query: String, chains: [Chain], tags: [AssetTag])
    case getAssetsList(deviceId: String, walletId: String, fromTimestamp: Int)

    case getDeviceNFTAssets(deviceId: String, walletId: String)
    case reportNft(deviceId: String, report: ReportNft)

    case scanTransaction(deviceId: String, payload: ScanTransactionPayload)

    case markets

    case addSupportDevice(deviceId: String, supportDeviceId: String)

    case getAuthNonce(deviceId: String)

    case getDeviceRewards(deviceId: String, walletId: String)
    case getDeviceRewardsEvents(deviceId: String, walletId: String)
    case getDeviceRewardsLeaderboard(deviceId: String)
    case getDeviceRedemptionOption(deviceId: String, code: String)
    case createDeviceReferral(deviceId: String, walletId: String, request: AuthenticatedRequest<ReferralCode>)
    case useDeviceReferralCode(deviceId: String, walletId: String, request: AuthenticatedRequest<ReferralCode>)
    case redeemDeviceRewards(deviceId: String, walletId: String, request: AuthenticatedRequest<RedemptionRequest>)

    case getNotifications(deviceId: String, fromTimestamp: Int)
    case markNotificationsRead(deviceId: String)

    case isDeviceRegistered(deviceId: String)

    public var baseUrl: URL {
        Constants.apiURL
    }

    public var method: HTTPMethod {
        switch self {
        case .getFiatQuotes,
            .getFiatAssets,
            .getSwapAssets,
            .getConfig,
            .getNameRecord,
            .getCharts,
            .getSubscriptions,
            .getDevice,
            .getTransactions,
            .getAsset,
            .getSearchAssets,
            .getSearch,
            .getAssetsList,
            .getPriceAlerts,
            .getDeviceNFTAssets,
            .markets,
            .getAuthNonce,
            .getDeviceRewards,
            .getDeviceRewardsEvents,
            .getDeviceRewardsLeaderboard,
            .getDeviceRedemptionOption,
            .getNotifications,
            .isDeviceRegistered:
            return .GET
        case .addSubscriptions,
            .addDevice,
            .getAssets,
            .addPriceAlerts,
            .scanTransaction,
            .getPrices,
            .addSupportDevice,
            .getFiatQuoteUrl,
            .reportNft,
            .createDeviceReferral,
            .useDeviceReferralCode,
            .redeemDeviceRewards,
            .markNotificationsRead:
            return .POST
        case .updateDevice:
            return .PUT
        case .deleteSubscriptions,
            .deleteDevice,
            .deletePriceAlerts:
            return .DELETE
        }
    }

    public var path: String {
        switch self {
        case .getFiatAssets(let type):
            return "/v1/fiat/assets/\(type.rawValue)"
        case .getFiatQuotes(let type, let assetId, _):
            return "/v1/fiat/quotes/\(type.rawValue)/\(assetId.identifier)"
        case .getFiatQuoteUrl:
            return "/v1/fiat/quotes/url"
        case .getSwapAssets:
            return "/v1/swap/assets"
        case .getConfig:
            return "/v1/config"
        case .getNameRecord(let name, let chain):
            return "/v1/name/resolve/\(name)?chain=\(chain)"
        case .getCharts(let assetId, _):
            return "/v1/charts/\(assetId.identifier)"
        case .getSubscriptions(let deviceId),
                .addSubscriptions(let deviceId, _),
                .deleteSubscriptions(let deviceId, _):
            return "/v1/devices/\(deviceId)/subscriptions"
        case .addDevice:
            return "/v1/devices"
        case .getDevice(let deviceId),
                .deleteDevice(let deviceId):
            return "/v1/devices/\(deviceId)"
        case .updateDevice(let device):
            return "/v1/devices/\(device.id)"
        case .getTransactions(let deviceId, let walletId, let assetId, let fromTimestamp):
            var path = "/v1/devices/\(deviceId)/wallets/\(walletId)/transactions?from_timestamp=\(fromTimestamp)"
            if let assetId {
                path += "&asset_id=\(assetId)"
            }
            return path
        case .getAsset(let id):
            return "/v1/assets/\(id.identifier.replacingOccurrences(of: "/", with: "%2F"))"
        case .getAssets:
            return "/v1/assets"
        case .getSearchAssets:
            return "/v1/assets/search"
        case .getSearch:
            return "/v1/search"
        case .getAssetsList(let deviceId, let walletId, let fromTimestamp):
            return "/v1/devices/\(deviceId)/wallets/\(walletId)/assets?from_timestamp=\(fromTimestamp)"
        case .getPrices:
            return "/v1/prices"
        case .getPriceAlerts(let deviceId, _):
            return "/v1/devices/\(deviceId)/price_alerts"
        case .addPriceAlerts(let deviceId, _), .deletePriceAlerts(let deviceId, _):
            return "/v1/devices/\(deviceId)/price_alerts"
        case .getDeviceNFTAssets(deviceId: let deviceId, walletId: let walletId):
            return "/v1/devices/\(deviceId)/wallets/\(walletId)/nft_assets"
        case .reportNft(let deviceId, _):
            return "/v1/devices/\(deviceId)/nft/report"
        case .scanTransaction(let deviceId, _):
            return "/v1/devices/\(deviceId)/scan/transaction"
        case .markets:
            return "/v1/markets"
        case .addSupportDevice(let deviceId, _):
            return "/v1/devices/\(deviceId)/support"
        case .getAuthNonce(let deviceId):
            return "/v1/devices/\(deviceId)/auth/nonce"
        case .getDeviceRewards(let deviceId, let walletId):
            return "/v1/devices/\(deviceId)/wallets/\(walletId)/rewards"
        case .getDeviceRewardsEvents(let deviceId, let walletId):
            return "/v1/devices/\(deviceId)/wallets/\(walletId)/rewards/events"
        case .getDeviceRewardsLeaderboard(let deviceId):
            return "/v1/devices/\(deviceId)/rewards/leaderboard"
        case .getDeviceRedemptionOption(let deviceId, let code):
            return "/v1/devices/\(deviceId)/rewards/redemptions/\(code)"
        case .createDeviceReferral(let deviceId, let walletId, _):
            return "/v1/devices/\(deviceId)/wallets/\(walletId)/rewards/referrals/create"
        case .useDeviceReferralCode(let deviceId, let walletId, _):
            return "/v1/devices/\(deviceId)/wallets/\(walletId)/rewards/referrals/use"
        case .redeemDeviceRewards(let deviceId, let walletId, _):
            return "/v1/devices/\(deviceId)/wallets/\(walletId)/rewards/redeem"
        case .getNotifications(let deviceId, let fromTimestamp):
            return "/v1/devices/\(deviceId)/notifications?from_timestamp=\(fromTimestamp)"
        case .markNotificationsRead(let deviceId):
            return "/v1/devices/\(deviceId)/notifications/read"
        case .isDeviceRegistered(let deviceId):
            return "/v1/devices/\(deviceId)/is_registered"
        }
    }

    public var data: RequestData {
        switch self {
        case .getFiatAssets,
            .getSwapAssets,
            .getConfig,
            .getNameRecord,
            .getSubscriptions,
            .getDevice,
            .deleteDevice,
            .getAssetsList,
            .getAsset,
            .getDeviceNFTAssets,
            .markets,
            .getAuthNonce,
            .getDeviceRewards,
            .getDeviceRewardsEvents,
            .getDeviceRewardsLeaderboard,
            .getDeviceRedemptionOption,
            .getNotifications,
            .markNotificationsRead,
            .getTransactions,
            .isDeviceRegistered:
            return .plain
        case .getFiatQuoteUrl(let request):
            return .encodable(request)
        case .getAssets(let value):
            return .encodable(value.map { $0.identifier })
        case .getPriceAlerts(_, let assetId):
            let params: [String: Any] = [
                "asset_id": assetId,
            ].compactMapValues { $0 }

            return .params(params)
        case let .getFiatQuotes(_, _, request):
            let params: [String: Any] = [
                "amount": request.amount,
                "currency": request.currency
            ]

            return .params(params)
        case .getCharts(_, let period):
            return .params([
                "period": period
            ])
        case .getPrices(let request):
            return .encodable(request)
        case .addSupportDevice(_, let supportDeviceId):
            return .encodable(SupportDeviceRequest(supportDeviceId: supportDeviceId))
        case .addSubscriptions(_, let subscriptions),
            .deleteSubscriptions(_, let subscriptions):
            return .encodable(subscriptions)
        case .addPriceAlerts(_, let priceAlerts),
            .deletePriceAlerts(_, let priceAlerts):
            return .encodable(priceAlerts)
        case .addDevice(let device),
            .updateDevice(let device):
            return .encodable(device)
        case .getSearchAssets(let query, let chains, let tags),
            .getSearch(let query, let chains, let tags):
            return .params([
                "query": query,
                "chains": chains.map { $0.rawValue }.joined(separator: ","),
                "tags": tags.map { $0.rawValue }.joined(separator: ",")
            ])
        case .scanTransaction(_, let payload):
            return .encodable(payload)
        case .reportNft(_, let report):
            return .encodable(report)
        case .createDeviceReferral(_, _, let request):
            return .encodable(request)
        case .useDeviceReferralCode(_, _, let request):
            return .encodable(request)
        case .redeemDeviceRewards(_, _, let request):
            return .encodable(request)
        }
    }
}

extension Encodable {
  var dictionary: [String: Any]? {
      guard let data = try? JSONEncoder().encode(self) else { return nil }
      return (try? JSONSerialization.jsonObject(with: data, options: [])).flatMap { $0 as? [String: Any] }
  }
}
