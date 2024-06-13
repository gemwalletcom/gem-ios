// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

struct BuyAssetInputViewModel {
    var amount: Double

    var quote: FiatQuote?
    var quotes: [FiatQuote]
}

// MARK: - Static

extension BuyAssetInputViewModel {
    static var `default`: BuyAssetInputViewModel {
        return BuyAssetInputViewModel(amount: defaultAmount, quote: nil, quotes: [])
    }

    static private var defaultAmount: Double {
        return 50
    }

    static var availableDefaultAmounts: [[Double]] {
        return [
            [50, 100, 200],
            [250, 500, 1000]
        ]
    }
}
