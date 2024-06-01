// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum URLAction {
    case walletConnect(uri: String)
    case walletConnectRequest
}

public struct URLParser {
    
    public  static func from(url: URL) throws -> URLAction {
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
