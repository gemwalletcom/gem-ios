// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct URLParser {
    
    public static func from(url: URL) throws -> URLAction {
        let urlComponents = Array(url.pathComponents.dropFirst());
        // universal links
        if url.host() == DeepLink.host || url.scheme == "gem" {
            if urlComponents.count >= 2 && urlComponents.first == "tokens" {
                let chain = try Chain(id: try urlComponents.getElement(safe: 1))
                return .asset(AssetId(chain: chain, tokenId: urlComponents.element(at: 2)))
            }
        }
        if url.absoluteString.contains("wc?uri") {
            guard let components = url.absoluteString.components(separatedBy: "://").last?.removingPercentEncoding, components.count > 1 else {
                throw AnyError("invalid wc url")
            }
            let uri = components.replacingOccurrences(of: "wc?uri=", with: "")
            return .walletConnect(uri: uri)
        } else if url.absoluteString.contains("wc?requestId") {
            return .walletConnectRequest
        }
        throw AnyError("url parser: unknown url")
    }
}
