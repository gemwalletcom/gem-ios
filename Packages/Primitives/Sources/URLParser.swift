// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum URLParserError: Error {
    case invalidURL(URL)
}

public enum URLParser {
    public static func from(url: URL) throws -> URLAction {
        // wallet connect
        if url.absoluteString.contains("wc?uri") {
            guard let components = url.absoluteString.components(separatedBy: "://").last?.removingPercentEncoding, components.count > 1 else {
                throw AnyError("invalid wc url")
            }
            let uri = components.replacingOccurrences(of: "wc?uri=", with: "")
            return .walletConnect(uri: uri)
        } else if url.absoluteString.contains("wc?requestId") {
            return .walletConnectRequest
        } else if url.absoluteString.contains("wc?sessionTopic") {
            guard let components = URLComponents(string: url.absoluteString),
                  let sessionTopic = components.queryItems?.first(where: { $0.name == "sessionTopic" })?.value else {
                throw AnyError("invalid sessionTopic url")
            }
            return .walletConnectSession(sessionTopic)
        }

        // universal links
        var urlComponents = Array(url.pathComponents.dropFirst())

        // For gem:// URLs like gem://join?code=gemcoder, the path component is in the host
        if url.scheme == "gem", urlComponents.isEmpty, let host = url.host() {
            urlComponents = [host]
        }

        if url.host() == DeepLink.host || url.scheme == "gem" {
            guard let path = urlComponents.first,
                  let pathComponent = DeepLink.PathComponent(rawValue: path) else {
                return .none
            }

            switch pathComponent {
            case .tokens:
                let chain = try Chain(id: urlComponents.required(at: 1, url: url))
                return .asset(AssetId(chain: chain, tokenId: urlComponents.element(at: 2)))
            case .swap:
                let fromId = try AssetId(id: urlComponents.required(at: 1, url: url))
                let toId = urlComponents.element(at: 2).flatMap { try? AssetId(id: $0) }
                return .swap(fromId, toId)
            case .perpetuals:
                return .perpetuals
            case .rewards, .join:
                return .rewards(code: url.queryValue(for: "code") ?? "")
            case .buy, .sell:
                return try parseFiat(url: url, urlComponents: urlComponents, type: pathComponent)
            case .setPriceAlert:
                let price: Double? = url.queryValue(for: "price")
                let assetId = try AssetId(id: urlComponents.required(at: 1, url: url))
                return .setPriceAlert(assetId, price: price)
            }
        }

        throw URLParserError.invalidURL(url)
    }

    private static func parseFiat(url: URL, urlComponents: [String], type: DeepLink.PathComponent) throws -> URLAction {
        let assetId = try AssetId(id: urlComponents.required(at: 1, url: url))
        let amount: Int? = url.queryValue(for: "amount")
        return switch type {
        case .buy: .buy(assetId, amount: amount)
        case .sell: .sell(assetId, amount: amount)
        default: .none
        }
    }
}

private extension Array where Element == String {
    func required(at index: Int, url: URL) throws -> String {
        guard let value = element(at: index) else {
            throw URLParserError.invalidURL(url)
        }
        return value
    }
}
