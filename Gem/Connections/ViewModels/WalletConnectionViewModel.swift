// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct WalletConnectionViewModel {
    let connection: WalletConnection
    
    var name: String {
        return connection.session.metadata.name
    }
    
    var imageUrl: URL? {
        if let url = URL(string: connection.session.metadata.icon) {
            if url.host() == nil {
                return URL(string: connection.session.metadata.url + connection.session.metadata.icon)
            }
            return url
        }
        return .none
    }
    
    var host: String? {
        return url?.host(percentEncoded: false)
    }
    
    var url: URL? {
        return URL(string: connection.session.metadata.url)
    }
}
