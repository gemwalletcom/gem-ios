// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct SwapQuoteInput: Hashable, Sendable {
    let fromAsset: AssetData?
    let toAsset: AssetData?
    let amount: String
    let isApprovalInProgress: Bool
}

// MARK: - Identifiable

extension SwapQuoteInput: Identifiable {
    var id: String {"\(fromAsset?.id ?? "")_\(toAsset?.id ?? "")_\(amount)" }
}
