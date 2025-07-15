// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension SwapData {
    static func mock() -> SwapData {
        SwapData(
            quote: .mock(),
            data: .mock()
        )
    }
}
