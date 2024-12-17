// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol CurrencyStorable: Sendable {
    var currency: String { get set }
}
