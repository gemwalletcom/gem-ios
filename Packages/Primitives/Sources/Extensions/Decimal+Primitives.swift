// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Decimal {
    public var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}
