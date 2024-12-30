// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct SwapQuoteInput: Equatable, Hashable, Sendable {
    let fromAsset: AssetData?
    let toAsset: AssetData?
    let amount: String
}

// MARK: - Identifiable

extension SwapQuoteInput: Identifiable {
    var id: String {
        guard let fromId = fromAsset?.id,
              let toId = toAsset?.id
        else { return "_\(amount)" }

        return "\(fromId)_\(toId)_\(amount)"
    }
}
