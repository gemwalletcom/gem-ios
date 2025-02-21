// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives

public struct WalletBarViewViewModel {
    public let name: String
    public let image: AssetImage

    public init(name: String, image: AssetImage) {
        self.name = name
        self.image = image
    }
}
