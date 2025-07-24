// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import ReownWalletKit

extension AppMetadata {
    var metadata: WalletConnectionSessionAppMetadata {
        WalletConnectionSessionAppMetadata(
            name: name,
            description: description,
            url: url,
            icon: icons.first {
                $0.contains(".png") || $0.contains(".jpg") || $0.contains(".jpeg")
            } ?? icons.first ?? .empty,
            redirectNative: redirect?.native,
            redirectUniversal: redirect?.universal
        )
    }
}
