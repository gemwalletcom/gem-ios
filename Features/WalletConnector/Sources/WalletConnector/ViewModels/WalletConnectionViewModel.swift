// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents

public struct WalletConnectionViewModel: Sendable {
    let connection: WalletConnection

    init(connection: WalletConnection) {
        self.connection = connection
    }

    var name: String {
        connection.session.metadata.name
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
        url?.host(percentEncoded: false)
    }

    var urlType: ContextMenuItemType? {
        guard let host,
              let url
        else {
            return nil
        }
        return .url(title: host, url: url)
    }
}

// MARK: - Private

extension WalletConnectionViewModel {
    private var url: URL? {
        URL(string: connection.session.metadata.url)
    }
}
