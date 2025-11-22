// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Validators
import BigInt
import Formatters

public struct FiatSellValidator: ValueValidator {
    public typealias Formatted = BigInt

    private let quote: FiatQuote?
    private let availableBalance: BigInt
    private let asset: Asset
    private let formatter = BigNumberFormatter.standard

    public init(
        quote: FiatQuote?,
        availableBalance: BigInt,
        asset: Asset
    ) {
        self.quote = quote
        self.availableBalance = availableBalance
        self.asset = asset
    }

    public func validate(_ value: BigInt) throws {
        guard let quote else { return }

        let amount = try formatter.number(from: String(quote.cryptoAmount), decimals: asset.decimals.asInt)

        guard amount <= availableBalance else {
            throw TransferAmountCalculatorError.insufficientBalance(asset)
        }
    }

    public var id: String { "FiatSellValidator" }
}
