// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemWalletConnectionSessionAppMetadata {
    public func map() -> WalletConnectionSessionAppMetadata {
        return WalletConnectionSessionAppMetadata(
            name: self.name,
            description: self.description,
            url: self.url,
            icon: self.icon
        )
    }
}

extension WalletConnectionSessionAppMetadata {
    public func map() -> GemWalletConnectionSessionAppMetadata {
        return GemWalletConnectionSessionAppMetadata(
            name: self.name,
            description: self.description,
            url: self.url,
            icon: self.icon
        )
    }
}
