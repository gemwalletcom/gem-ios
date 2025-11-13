// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Perpetuals

public extension AutocloseField {
    static func mock(
        price: Double? = nil,
        originalPrice: Double? = nil,
        formattedPrice: String? = nil,
        isValid: Bool = false,
        orderId: UInt64? = nil
    ) -> AutocloseField {
        AutocloseField(
            price: price,
            originalPrice: originalPrice,
            formattedPrice: formattedPrice,
            isValid: isValid,
            orderId: orderId
        )
    }
}
