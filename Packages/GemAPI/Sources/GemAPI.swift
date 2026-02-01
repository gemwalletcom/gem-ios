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
    case getAsset(AssetId)
    case getAssets([AssetId])
    case getSearchAssets(query: String, chains: [Chain], tags: [AssetTag])
    case getSearch(query: String, chains: [Chain], tags: [AssetTag])
    case markets

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
            .getAsset,
            .getSearchAssets,
            .getSearch,
            .markets:
            return .GET
        case .getAssets,
            .getPrices,
            .getFiatQuoteUrl:
            return .POST
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
        case .getAsset(let id):
            return "/v1/assets/\(id.identifier.replacingOccurrences(of: "/", with: "%2F"))"
        case .getAssets:
            return "/v1/assets"
        case .getSearchAssets:
            return "/v1/assets/search"
        case .getSearch:
            return "/v1/search"
        case .getPrices:
            return "/v1/prices"
        case .markets:
            return "/v1/markets"
        }
    }

    public var data: RequestData {
        switch self {
        case .getFiatAssets,
            .getSwapAssets,
            .getConfig,
            .getNameRecord,
            .getAsset,
            .markets:
            return .plain
        case .getFiatQuoteUrl(let request):
            return .encodable(request)
        case .getAssets(let value):
            return .encodable(value.map { $0.identifier })
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
        case .getSearchAssets(let query, let chains, let tags),
            .getSearch(let query, let chains, let tags):
            return .params([
                "query": query,
                "chains": chains.map { $0.rawValue }.joined(separator: ","),
                "tags": tags.map { $0.rawValue }.joined(separator: ",")
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
