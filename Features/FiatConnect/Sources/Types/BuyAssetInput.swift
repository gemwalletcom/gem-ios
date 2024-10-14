// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct BuyAssetInput: Sendable{
    public var amount: Double
    public var quote: FiatQuote?

    public init(amount: Double, quote: FiatQuote? = nil) {
        self.amount = amount
        self.quote = quote
    }
}

// MARK: - Static

 extension BuyAssetInput {
     public static let `default`: BuyAssetInput = BuyAssetInput(amount: defaultAmount)
     public static let suggestedAmounts: [Double] = [100, 250]

     public static func randomAmount(current: Double) -> Double? {
         Double(Int.random(in: Int(defaultAmount)..<Int(maxAvailableAmount)))
     }

     static private let defaultAmount: Double = 50
     static private let maxAvailableAmount: Double = 1000
 }
