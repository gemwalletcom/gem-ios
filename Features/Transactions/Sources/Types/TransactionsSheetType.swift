// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum TransactionsSheetType: Identifiable {
    case filter
    case selectAsset(SelectAssetType)

    public var id: String {
        switch self {
        case .filter: "filter"
        case .selectAsset(let type): "selectAsset-\(type.id)"
        }
    }
}
