// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum AssetSelectionType: Hashable {
    case regular(SelectAssetInput)
    case recent(SelectAssetInput)

    public var input: SelectAssetInput {
        switch self {
        case .regular(let input), .recent(let input):
            return input
        }
    }
}
