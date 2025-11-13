// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct AutocloseField {
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

    public init(price: Double?, originalPrice: Double?, formattedPrice: String?, isValid: Bool, orderId: UInt64?) {
        self.price = price
        self.originalPrice = originalPrice
        self.formattedPrice = formattedPrice
        self.isValid = isValid
        self.orderId = orderId
    }
}
