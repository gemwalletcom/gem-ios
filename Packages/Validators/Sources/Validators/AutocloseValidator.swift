// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters

public struct AutocloseValidator: TextValidator {
    private let type: TpslType
    private let marketPrice: Double

    public init(
        type: TpslType,
        marketPrice: Double
    ) {
        self.marketPrice = marketPrice
        self.type = type
    }

    public func validate(_ text: String) throws {
        guard !text.isEmpty else { return }

        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal

        guard let price = formatter.number(from: text)?.doubleValue, price > 0 else {
            throw TransferError.invalidAmount
        }

        switch type {
        case .takeProfit:
            guard price > marketPrice else {
                throw PerpetualError.invalidAutoclose(type: type)
            }
        case .stopLoss:
            guard price < marketPrice else {
                throw PerpetualError.invalidAutoclose(type: type)
            }
        }
    }

    public var id: String { "TakeProfitValidator" }
}
