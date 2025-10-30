// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters

public struct AutocloseValidator: TextValidator {
    private let type: TpslType
    private let marketPrice: Double
    private let direction: PerpetualDirection

    public init(
        type: TpslType,
        marketPrice: Double,
        direction: PerpetualDirection
    ) {
        self.marketPrice = marketPrice
        self.type = type
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

        let isValid = switch (type, direction) {
        case (.takeProfit, .long), (.stopLoss, .short): price > marketPrice
        case (.takeProfit, .short), (.stopLoss, .long): price < marketPrice
        }

        guard isValid else {
            throw PerpetualError.invalidAutoclose(type: type, direction: direction)
        }
    }

    public var id: String { "AutocloseValidator" }
}
