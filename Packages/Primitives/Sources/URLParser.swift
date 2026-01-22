// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum URLParserError: Error {
    case invalidURL(URL)
}

public enum URLParser {
    private static let localePrefixPattern = "^[a-z]{2}(-[a-z]{2})?$"

    public static func from(url: URL) throws -> URLAction {
        if let walletConnectAction = try parseWalletConnect(url: url) {
            return .walletConnect(walletConnectAction)
        }
        return try parseDeepLink(url: url)
    }

    private static func parseWalletConnect(url: URL) throws -> WalletConnectAction? {
        if url.absoluteString.contains("wc?uri") {
            guard let components = url.absoluteString.components(separatedBy: "://").last?.removingPercentEncoding, components.count > 1 else {
                throw AnyError("invalid wc url")
            }
            let uri = components.replacingOccurrences(of: "wc?uri=", with: "")
            return .connect(uri: uri)
        } else if url.absoluteString.contains("wc?requestId") {
            return .request
        } else if url.absoluteString.contains("wc?sessionTopic") {
            guard let components = URLComponents(string: url.absoluteString),
                  let sessionTopic = components.queryItems?.first(where: { $0.name == "sessionTopic" })?.value else {
                throw AnyError("invalid sessionTopic url")
            }
            return .session(sessionTopic)
        }
        return nil
    }

    private static func parseDeepLink(url: URL) throws -> URLAction {
        var urlComponents = Array(url.pathComponents.dropFirst())

        if url.scheme == "gem", let host = url.host() {
            urlComponents = [host] + urlComponents
        }

        urlComponents = Self.strippingLocalePrefix(from: urlComponents)

        if url.host() == DeepLink.host || url.scheme == "gem" {
            guard let path = urlComponents.first,
                  let pathComponent = DeepLink.PathComponent(rawValue: path) else {
                throw URLParserError.invalidURL(url)
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
                let code = urlComponents.element(at: 1) ?? url.queryValue(for: "code")
                return .rewards(code: code)
            case .gift:
                let code = urlComponents.element(at: 1) ?? url.queryValue(for: "code")
                return .gift(code: code)
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
        switch type {
        case .buy: return .buy(assetId, amount: amount)
        case .sell: return .sell(assetId, amount: amount)
        default: throw URLParserError.invalidURL(url)
        }
    }

    private static func strippingLocalePrefix(from components: [String]) -> [String] {
        guard let first = components.first,
              first.range(of: localePrefixPattern, options: .regularExpression) != nil,
              DeepLink.PathComponent(rawValue: first) == nil else {
            return components
        }
        return Array(components.dropFirst())
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
