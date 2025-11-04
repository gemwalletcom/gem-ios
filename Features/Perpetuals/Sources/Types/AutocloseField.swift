// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

struct AutocloseField {
    let price: Double?
    let originalPrice: Double?
    let formattedPrice: String?
    let isValid: Bool
    let orderId: UInt64?

    var hasChanged: Bool { price != originalPrice }
    var isCleared: Bool { originalPrice != nil && price == nil }
    var hasExisting: Bool { originalPrice != nil }

    var shouldSet: Bool { isValid && hasChanged }
    var shouldUpdate: Bool { shouldSet || isCleared }
    var shouldCancel: Bool { isCleared || (shouldSet && hasExisting) }
}
