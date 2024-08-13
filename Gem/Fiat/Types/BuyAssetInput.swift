// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

struct BuyAssetInput {
    var amount: Double
    var quote: FiatQuote?
}

// MARK: - Static

 extension BuyAssetInput {
     static let `default`: BuyAssetInput = BuyAssetInput(amount: defaultAmount)
     static let suggestedAmounts: [Double] = [100, 250]

     static func randomAmount(current: Double) -> Double? {
         availableAmounts.filter({ current != $0 }).randomElement()
     }

     static private let defaultAmount: Double = 50
     static private let maxAvailableAmount: Double = 1000
     static private let availableAmounts: [Double] = Array(stride(from: defaultAmount, through: maxAvailableAmount, by: defaultAmount))
 }
