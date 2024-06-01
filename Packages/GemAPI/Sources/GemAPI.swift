// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient
import Primitives

public enum GemAPI: TargetType {
    case getIpAddress
    case getPrices(AssetPricesRequest)
    case getFiatOnRampQuotes(Asset, FiatBuyRequest)
    case getFiatOnRampAssets
    case getSwapAssets
    case getConfig
    case getNodes
    case getNameRecord(name: String, chain: String)
    case getCharts(AssetId, currency: String, period: String)
    
    case getDevice(deviceId: String)
    case addDevice(device: Device)
    case updateDevice(device: Device)
    case deleteDevice(deviceId: String)
    
    case getSubscriptions(deviceId: String)
    case addSubscriptions(deviceId: String, subscriptions: [Subscription])
    case deleteSubscriptions(deviceId: String, subscriptions: [Subscription])
    
    case getTransactions(deviceId: String, options: TransactionsFetchOption)
    
    case getAsset(AssetId)
    case getAssets([AssetId])
    case getSwap(SwapQuoteRequest)
    case getSearchAssets(query: String, chains: [Chain])
    case getAssetsList(deviceId: String, walletIndex: Int, fromTimestamp: Int)
    
    public var baseUrl: URL {
        return URL(string: "https://api.gemwallet.com")!
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getIpAddress,
            .getFiatOnRampQuotes,
            .getFiatOnRampAssets,
            .getSwapAssets,
            .getConfig,
            .getNodes,
            .getNameRecord,
            .getCharts,
            .getSubscriptions,
            .getDevice,
            .getTransactions,
            .getAsset,
            .getSearchAssets,
            .getAssetsList:
            return .GET
        case .getPrices,
            .addSubscriptions,
            .addDevice,
            .getSwap,
            .getAssets:
            return .POST
        case .updateDevice:
            return .PUT
        case .deleteSubscriptions,
            .deleteDevice:
            return .DELETE
        }
    }
    
    public var path: String {
        switch self {
        case .getIpAddress:
            return "/v1/ip_address"
        case .getPrices:
            return "/v1/prices"
        case .getFiatOnRampQuotes(let asset, _):
            return "/v1/fiat/on_ramp/quotes/\(asset.id.identifier)"
        case .getFiatOnRampAssets:
            return "/v1/fiat/on_ramp/assets"
        case .getSwapAssets:
            return "/v1/swap/assets"
        case .getConfig:
            return "/v1/config"
        case .getNodes:
            return "/v1/nodes"
        case .getNameRecord(let name, let chain):
            return "/v1/name/resolve/\(name)?chain=\(chain)"
        case .getCharts(let assetId, _, _):
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
            return "/v1/transactions/by_device_id/\(deviceId)"
        case .getAsset(let id):
            return "/v1/assets/\(id.identifier.replacingOccurrences(of: "/", with: "%2F"))"
        case .getSwap:
            return "/v1/swap/quote"
        case .getAssets:
            return "/v1/assets"
        case .getSearchAssets:
            return "/v1/assets/search"
        case .getAssetsList(let deviceId, let walletIndex, let fromTimestamp):
            return "/v1/assets/by_device_id/\(deviceId)?wallet_index=\(walletIndex)&from_timestamp=\(fromTimestamp)"
        }
    }
    
    public var task: Task {
        switch self {
        case .getIpAddress,
            .getFiatOnRampAssets,
            .getSwapAssets,
            .getConfig,
            .getNodes,
            .getNameRecord,
            .getSubscriptions,
            .getDevice,
            .deleteDevice,
            .getAssetsList,
            .getAsset:
            return .plain
        case .getPrices(let value):
            return .encodable(value)
        case .getAssets(let value):
            return .encodable(value.map { $0.identifier })
        case .getFiatOnRampQuotes(_, let value):
            return .params([
                "amount": value.fiatAmount,
                "currency": value.fiatCurrency,
                "wallet_address": value.walletAddress,
            ])
        case .getCharts(_, let currency, let period):
            return .params([
                "period": period,
                "currency": currency
            ])
        case .addSubscriptions(_, let subscriptions),
            .deleteSubscriptions(_, let subscriptions):
            return .encodable(subscriptions)
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
        case .getSwap(let request):
            return .encodable(request)
        case .getSearchAssets(let query, let chains):
            return .params([
                "query": query,
                "chains": chains.map { $0.rawValue }.joined(separator: ",")
            ])
        }
    }
}

extension Encodable {
  var dictionary: [String: Any]? {
      guard let data = try? JSONEncoder().encode(self) else { return nil }
      return (try? JSONSerialization.jsonObject(with: data, options: [])).flatMap { $0 as? [String: Any] }
  }
}
