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
            icon: icons.filter { $0.contains(".png") }.first ?? icons.first ?? .empty,
            redirectNative: redirect?.native,
            redirectUniversal: redirect?.universal
        )
    }
}
