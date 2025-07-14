// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents

public struct WalletConnectionViewModel: Sendable {
    let connection: WalletConnection

    init(connection: WalletConnection) {
        self.connection = connection
    }

    var nameText: String {
        connection.session.metadata.shortName
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
    
    var hostText: String? {
        url?.cleanHost()
    }

    var url: URL? {
        URL(string: connection.session.metadata.url)
    }
}
