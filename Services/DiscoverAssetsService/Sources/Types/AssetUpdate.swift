// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AssetUpdate: Sendable {
    public let wallet: Wallet
    public let assets: [String]
}
