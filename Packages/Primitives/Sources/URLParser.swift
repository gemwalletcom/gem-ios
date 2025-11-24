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
        let urlComponents = Array(url.pathComponents.dropFirst())

        if url.host() == DeepLink.host || url.scheme == "gem" {
            guard let path = urlComponents.first else {
                throw URLParserError.invalidURL(url)
            }

            let componentsCount = urlComponents.count
            switch path {
            case "tokens" where componentsCount >= 2:
                let chain = try Chain(id: urlComponents.getElement(safe: 1))
                return .asset(AssetId(chain: chain, tokenId: urlComponents.element(at: 2)))
            case "swap" where componentsCount >= 2:
                let fromId = try AssetId(id: urlComponents[1])
                let toId: AssetId? = (urlComponents.count >= 3) ? try AssetId(id: urlComponents[2]) : nil
                return .swap(fromId, toId)
            case "perpetuals":
                return .perpetuals
            default:
                throw URLParserError.invalidURL(url)
            }
        }

        throw URLParserError.invalidURL(url)
    }
}
