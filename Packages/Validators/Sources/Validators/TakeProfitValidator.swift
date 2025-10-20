// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters

public struct TakeProfitValidator: TextValidator {
    private let marketPrice: Double
    private let direction: PerpetualDirection

    public init(
        marketPrice: Double,
        direction: PerpetualDirection
    ) {
        self.marketPrice = marketPrice
        self.direction = direction
    }

    public func validate(_ text: String) throws {
        guard !text.isEmpty else { return }

        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal

        guard let price = formatter.number(from: text)?.doubleValue, price > 0 else {
            throw TransferError.invalidAmount
        }

        switch direction {
        case .long:
            guard price > marketPrice else {
                throw PerpetualError.invalidTakeProfitPrice(direction: direction)
            }
        case .short:
            guard price < marketPrice else {
                throw PerpetualError.invalidTakeProfitPrice(direction: direction)
            }
        }
    }

    public var id: String { "TakeProfitValidator" }
}
