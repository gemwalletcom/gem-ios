// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient
import Primitives

public enum GemAPI: TargetType {
    case getFiatOnRampAssets
    case getFiatOffRampAssets
    case getFiatQuotes(Asset, FiatQuoteRequest)
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
    case addSubscriptions(deviceId: String, subscriptions: [Subscription])
    case deleteSubscriptions(deviceId: String, subscriptions: [Subscription])
    
    case getPriceAlerts(deviceId: String)
    case addPriceAlerts(deviceId: String, priceAlerts: [PriceAlert])
    case deletePriceAlerts(deviceId: String, priceAlerts: [PriceAlert])

    case getTransactions(deviceId: String, options: TransactionsFetchOption)
    
    case getAsset(AssetId)
    case getAssets([AssetId])
    case getSearchAssets(query: String, chains: [Chain], tags: [AssetTag])
    case getAssetsList(deviceId: String, walletIndex: Int, fromTimestamp: Int)
    
    case getNFTAssets(deviceId: String, walletIndex: Int)
    
    case scanTransaction(payload: ScanTransactionPayload)
    
    case markets

    case addSupportDevice(device: SupportDevice)
    
    public var baseUrl: URL {
        return URL(string: "https://api.gemwallet.com")!
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getFiatQuotes,
            .getFiatOnRampAssets,
            .getFiatOffRampAssets,
            .getSwapAssets,
            .getConfig,
            .getNameRecord,
            .getCharts,
            .getSubscriptions,
            .getDevice,
            .getTransactions,
            .getAsset,
            .getSearchAssets,
            .getAssetsList,
            .getPriceAlerts,
            .getNFTAssets,
            .markets:
            return .GET
        case .addSubscriptions,
            .addDevice,
            .getAssets,
            .addPriceAlerts,
            .scanTransaction,
            .getPrices,
            .addSupportDevice:
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
        case .getFiatOnRampAssets:
            return "/v1/fiat/on_ramp/assets"
        case .getFiatOffRampAssets:
            return "/v1/fiat/off_ramp/assets"
        case .getFiatQuotes(let asset, _):
            return "/v1/fiat/quotes/\(asset.id.identifier)"
        case .getSwapAssets:
            return "/v1/swap/assets"
        case .getConfig:
            return "/v1/config"
        case .getNameRecord(let name, let chain):
            return "/v1/name/resolve/\(name)?chain=\(chain)"
        case .getCharts(let assetId, _):
            return "/v1/charts/\(assetId.identifier)"
        case .getSubscriptions(let deviceId):
            return "/v1/subscriptions/\(deviceId)"
        case .addSubscriptions(let deviceId, _),
                .deleteSubscriptions(let deviceId, _):
            return "/v1/subscriptions/\(deviceId)"
        case .addDevice:
            return "/v1/devices"
        case .getDevice(let deviceId),
                .deleteDevice(let deviceId):
            return "/v1/devices/\(deviceId)"
        case .updateDevice(let device):
            return "/v1/devices/\(device.id)"
        case .getTransactions(let deviceId, _):
            return "/v2/transactions/device/\(deviceId)"
        case .getAsset(let id):
            return "/v1/assets/\(id.identifier.replacingOccurrences(of: "/", with: "%2F"))"
        case .getAssets:
            return "/v1/assets"
        case .getSearchAssets:
            return "/v1/assets/search"
        case .getAssetsList(let deviceId, let walletIndex, let fromTimestamp):
            return "/v1/assets/device/\(deviceId)?wallet_index=\(walletIndex)&from_timestamp=\(fromTimestamp)"
        case .getPrices:
            return "/v1/prices"
        case .getPriceAlerts(let deviceId), .addPriceAlerts(let deviceId, _), .deletePriceAlerts(let deviceId, _):
            return "/v1/price_alerts/\(deviceId)"
        case .getNFTAssets(deviceId: let deviceId, walletIndex: let walletIndex):
            return "/v1/nft/assets/device/\(deviceId)?wallet_index=\(walletIndex)"
        case .scanTransaction:
            return "/v1/scan/transaction"
        case .markets:
            return "/v1/markets"
        case .addSupportDevice:
            return "/v1/support/add_device"
        }
    }
    
    public var data: RequestData {
        switch self {
        case .getFiatOnRampAssets,
            .getFiatOffRampAssets,
            .getSwapAssets,
            .getConfig,
            .getNameRecord,
            .getSubscriptions,
            .getDevice,
            .deleteDevice,
            .getAssetsList,
            .getAsset,
            .getPriceAlerts,
            .getNFTAssets,
            .markets:
            return .plain
        case .getAssets(let value):
            return .encodable(value.map { $0.identifier })
        case let .getFiatQuotes(_, value):
            let params: [String: Any] = [
                "type": value.type.rawValue,
                "fiat_amount": value.fiatAmount,
                "crypto_value": value.cryptoValue as Any?,
                "currency": value.fiatCurrency,
                "wallet_address": value.walletAddress
            ].compactMapValues { $0 }
            
            return .params(params)
        case .getCharts(_, let period):
            return .params([
                "period": period
            ])
        case .getPrices(let request):
            return .encodable(request)
        case .addSupportDevice(let device):
            return .encodable(device)
        case .addSubscriptions(_, let subscriptions),
            .deleteSubscriptions(_, let subscriptions):
            return .encodable(subscriptions)
        case .addPriceAlerts(_, let priceAlerts),
            .deletePriceAlerts(_, let priceAlerts):
            return .encodable(priceAlerts)
        case .addDevice(let device),
            .updateDevice(let device):
            return .encodable(device)
        case .getTransactions(_, let options):
            let params: [String: Any] = [
                "wallet_index": options.wallet_index,
                "asset_id": options.asset_id as Any?,
                "from_timestamp": options.from_timestamp as Any?,
            ].compactMapValues { $0 }
            
            return .params(params)
        case .getSearchAssets(let query, let chains, let tags):
            return .params([
                "query": query,
                "chains": chains.map { $0.rawValue }.joined(separator: ","),
                "tags": tags.map { $0.rawValue }.joined(separator: ",")
            ])
        case .scanTransaction(let payload):
            return .encodable(payload)
        }
    }
}

extension Encodable {
  var dictionary: [String: Any]? {
      guard let data = try? JSONEncoder().encode(self) else { return nil }
      return (try? JSONSerialization.jsonObject(with: data, options: [])).flatMap { $0 as? [String: Any] }
  }
}
