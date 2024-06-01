// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import WalletCore
import WalletCorePrimitives

public enum ExplorerService {
    
    public static func transactionUrl(chain: Chain, hash: String) -> URL {
        let url = URL(string: Gemstone.Explorer().getTransactionUrl(chain: chain.id, transactionId: hash))!
        return url.appendTag()
    }

    public static func addressUrl(chain: Chain, address: String) -> URL {
        let url = URL(string: Gemstone.Explorer().getAddressUrl(chain: chain.id, address: address))!
        return url.appendTag()
    }
    
    public static func tokenUrl(chain: Chain, address: String) -> URL? {
        if let url = Gemstone.Explorer().getTokenUrl(chain: chain.id, address: address) {
            return URL(string: url)
        }
        return .none
    }

    public static func hostName(url: URL) -> String {
        guard let host = url.host else {
            return url.absoluteString
        }
        return Gemstone.Explorer().getNameByHost(host: host) ?? host
    }
}

extension URL {
    static let prefix = [
        "blockchair.com": [URLQueryItem(name: "from", value: "gemwallet")],
    ]

    public func appendTag() -> URL {
        if let host = host, let value = Self.prefix[host] {
            var newUrl = self
            newUrl.append(queryItems: value)
            return newUrl
        }
        return self
    }
}
