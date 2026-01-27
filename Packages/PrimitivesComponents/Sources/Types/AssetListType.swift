// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum AssetListType: Sendable, Identifiable {
    case wallet
    case manage
    case view
    case copy(ReceiveAssetType)
    case price

    public var id: String {
        switch self {
        case .wallet: "wallet"
        case .manage: "manage"
        case .view: "view"
        case .copy(let type): "copy_\(type.id)"
        case .price: "price"
        }
    }
}
