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
            guard let path = urlComponents.first,
                  let pathComponent = DeepLink.PathComponent(rawValue: path) else {
                return .none
            }

            switch pathComponent {
            case .tokens:
                guard let chainId = urlComponents.element(at: 1) else {
                    throw URLParserError.invalidURL(url)
                }
                let chain = try Chain(id: chainId)
                return .asset(AssetId(chain: chain, tokenId: urlComponents.element(at: 2)))
            case .swap:
                guard let fromIdString = urlComponents.element(at: 1) else {
                    throw URLParserError.invalidURL(url)
                }
                let fromId = try AssetId(id: fromIdString)
                let toId: AssetId? = urlComponents.element(at: 2).flatMap { try? AssetId(id: $0) }
                return .swap(fromId, toId)
            case .perpetuals:
                return .perpetuals
            }
        }

        throw URLParserError.invalidURL(url)
    }
}
