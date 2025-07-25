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
            icon: icons.first { icon in
                [".png", ".jpg", ".jpeg"].contains { icon.contains($0) }
            } ?? icons.first ?? .empty,
            redirectNative: redirect?.native,
            redirectUniversal: redirect?.universal
        )
    }
}
