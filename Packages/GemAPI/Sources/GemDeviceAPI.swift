// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient
import Primitives

public enum GemDeviceAPI: TargetType {
    case getDevice(deviceId: String)
    case addDevice(device: Device)
    case updateDevice(device: Device)
    case deleteDevice(deviceId: String)
    case isDeviceRegistered(deviceId: String)
    case migrateDevice(request: MigrateDeviceIdRequest)

    case getSubscriptions(deviceId: String)
    case addSubscriptions(deviceId: String, subscriptions: [WalletSubscription])
    case deleteSubscriptions(deviceId: String, walletIds: [String])

    case getPriceAlerts(deviceId: String, assetId: String?)
    case addPriceAlerts(deviceId: String, priceAlerts: [PriceAlert])
    case deletePriceAlerts(deviceId: String, priceAlerts: [PriceAlert])

    case getTransactions(deviceId: String, walletId: String, assetId: String?, fromTimestamp: Int)
    case getAssetsList(deviceId: String, walletId: String, fromTimestamp: Int)
    case getDeviceNFTAssets(deviceId: String, walletId: String)

    case reportNft(deviceId: String, report: ReportNft)
    case scanTransaction(deviceId: String, payload: ScanTransactionPayload)
    case addSupportDevice(deviceId: String, supportDeviceId: String)

    case getAuthNonce(deviceId: String)

    case getDeviceRewards(deviceId: String, walletId: String)
    case getDeviceRewardsEvents(deviceId: String, walletId: String)
    case getDeviceRedemptionOption(deviceId: String, code: String)
    case createDeviceReferral(deviceId: String, walletId: String, request: AuthenticatedRequest<ReferralCode>)
    case useDeviceReferralCode(deviceId: String, walletId: String, request: AuthenticatedRequest<ReferralCode>)
    case redeemDeviceRewards(deviceId: String, walletId: String, request: AuthenticatedRequest<RedemptionRequest>)

    case getNotifications(deviceId: String, fromTimestamp: Int)
    case markNotificationsRead(deviceId: String)

    public var baseUrl: URL {
        Constants.apiURL
    }

    public var method: HTTPMethod {
        switch self {
        case .getDevice,
            .getSubscriptions,
            .getTransactions,
            .getAssetsList,
            .getPriceAlerts,
            .getDeviceNFTAssets,
            .getAuthNonce,
            .getDeviceRewards,
            .getDeviceRewardsEvents,
            .getDeviceRedemptionOption,
            .getNotifications,
            .isDeviceRegistered:
            return .GET
        case .addDevice,
            .addSubscriptions,
            .addPriceAlerts,
            .scanTransaction,
            .addSupportDevice,
            .reportNft,
            .migrateDevice,
            .createDeviceReferral,
            .useDeviceReferralCode,
            .redeemDeviceRewards,
            .markNotificationsRead:
            return .POST
        case .updateDevice:
            return .PUT
        case .deleteDevice,
            .deleteSubscriptions,
            .deletePriceAlerts:
            return .DELETE
        }
    }

    public var path: String {
        switch self {
        case .addDevice:
            return "/v2/devices"
        case .getDevice,
            .deleteDevice,
            .updateDevice:
            return "/v2/devices"
        case .isDeviceRegistered:
            return "/v2/devices/is_registered"
        case .migrateDevice:
            return "/v2/devices/migrate"
        case .getSubscriptions,
            .addSubscriptions,
            .deleteSubscriptions:
            return "/v2/devices/subscriptions"
        case .getPriceAlerts(let deviceId, _),
            .addPriceAlerts(let deviceId, _),
            .deletePriceAlerts(let deviceId, _):
            return "/v1/devices/\(deviceId)/price_alerts"
        case .getTransactions(_, _, let assetId, let fromTimestamp):
            var path = "/v2/devices/transactions?from_timestamp=\(fromTimestamp)"
            if let assetId {
                path += "&asset_id=\(assetId)"
            }
            return path
        case .getAssetsList(_, _, let fromTimestamp):
            return "/v2/devices/assets?from_timestamp=\(fromTimestamp)"
        case .getDeviceNFTAssets:
            return "/v2/devices/nft_assets"
        case .reportNft:
            return "/v2/devices/nft/report"
        case .scanTransaction:
            return "/v2/devices/scan/transaction"
        case .addSupportDevice:
            return "/v2/devices/support"
        case .getAuthNonce:
            return "/v2/devices/auth/nonce"
        case .getDeviceRewards:
            return "/v2/devices/rewards"
        case .getDeviceRewardsEvents:
            return "/v2/devices/rewards/events"
        case .getDeviceRedemptionOption(_, let code):
            return "/v2/devices/rewards/redemptions/\(code)"
        case .createDeviceReferral:
            return "/v2/devices/rewards/referrals/create"
        case .useDeviceReferralCode:
            return "/v2/devices/rewards/referrals/use"
        case .redeemDeviceRewards:
            return "/v2/devices/rewards/redeem"
        case .getNotifications(_, let fromTimestamp):
            return "/v2/devices/notifications?from_timestamp=\(fromTimestamp)"
        case .markNotificationsRead:
            return "/v2/devices/notifications/read"
        }
    }

    public var headers: [String: String] {
        switch self {
        case .isDeviceRegistered(let deviceId),
            .getDevice(let deviceId),
            .deleteDevice(let deviceId),
            .reportNft(let deviceId, _),
            .scanTransaction(let deviceId, _),
            .addSupportDevice(let deviceId, _),
            .getAuthNonce(let deviceId),
            .getNotifications(let deviceId, _),
            .markNotificationsRead(let deviceId),
            .getDeviceRedemptionOption(let deviceId, _),
            .getSubscriptions(let deviceId),
            .addSubscriptions(let deviceId, _),
            .deleteSubscriptions(let deviceId, _):
            return ["x-device-id": deviceId]
        case .addDevice(let device),
            .updateDevice(let device):
            return ["x-device-id": device.id]
        case .getTransactions(let deviceId, let walletId, _, _),
            .getAssetsList(let deviceId, let walletId, _),
            .getDeviceNFTAssets(let deviceId, let walletId),
            .getDeviceRewards(let deviceId, let walletId),
            .getDeviceRewardsEvents(let deviceId, let walletId),
            .createDeviceReferral(let deviceId, let walletId, _),
            .useDeviceReferralCode(let deviceId, let walletId, _),
            .redeemDeviceRewards(let deviceId, let walletId, _):
            return ["x-device-id": deviceId, "x-wallet-id": walletId]
        default:
            return [:]
        }
    }

    public var data: RequestData {
        switch self {
        case .getDevice,
            .deleteDevice,
            .getSubscriptions,
            .getAssetsList,
            .getDeviceNFTAssets,
            .getAuthNonce,
            .getDeviceRewards,
            .getDeviceRewardsEvents,
            .getDeviceRedemptionOption,
            .getNotifications,
            .markNotificationsRead,
            .getTransactions,
            .isDeviceRegistered:
            return .plain
        case .getPriceAlerts(_, let assetId):
            let params: [String: Any] = [
                "asset_id": assetId,
            ].compactMapValues { $0 }
            return .params(params)
        case .addDevice(let device),
            .updateDevice(let device):
            return .encodable(device)
        case .migrateDevice(let request):
            return .encodable(request)
        case .addSubscriptions(_, let subscriptions):
            return .encodable(subscriptions)
        case .deleteSubscriptions(_, let walletIds):
            return .encodable(walletIds)
        case .addPriceAlerts(_, let priceAlerts),
            .deletePriceAlerts(_, let priceAlerts):
            return .encodable(priceAlerts)
        case .scanTransaction(_, let payload):
            return .encodable(payload)
        case .reportNft(_, let report):
            return .encodable(report)
        case .addSupportDevice(_, let supportDeviceId):
            return .encodable(SupportDeviceRequest(supportDeviceId: supportDeviceId))
        case .createDeviceReferral(_, _, let request):
            return .encodable(request)
        case .useDeviceReferralCode(_, _, let request):
            return .encodable(request)
        case .redeemDeviceRewards(_, _, let request):
            return .encodable(request)
        }
    }
}
