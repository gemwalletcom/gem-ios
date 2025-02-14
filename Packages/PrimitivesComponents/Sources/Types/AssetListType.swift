// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum AssetListType: Codable, Sendable, Identifiable {
    case wallet
    case manage
    case view
    case copy
    case price

    public var id: Self { self }
}
