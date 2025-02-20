// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public struct SwapHeaderInput: Sendable {
    let from: SwapAssetInput
    let to: SwapAssetInput

    public init(from: SwapAssetInput, to: SwapAssetInput) {
        self.from = from
        self.to = to
    }
}
