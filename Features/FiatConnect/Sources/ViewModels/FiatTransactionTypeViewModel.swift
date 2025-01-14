// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

public struct FiatTransactionTypeViewModel: Sendable {
    public let type: FiatTransactionType

    public init(type: FiatTransactionType) {
        self.type = type
    }
}

public extension FiatTransactionTypeViewModel {
    static let defaultBuyMaxAmount: Double = 1000

    var suggestedAmounts: [Double] {
        switch type {
        case .buy: [100, 250]
        case .sell: [25 , 50] // specified as %
        }
    }

    var defaultAmount: Double {
        switch type {
        case .buy: 50
        case .sell: .zero
        }
    }

    func randomAmount(maxAmount: Double) -> Double? {
        switch type {
        case .buy: Double(Int.random(in: Int(defaultAmount)..<Int(maxAmount)))
        case .sell: .none
        }
    }

    var title: String {
        switch type {
        case .buy: Localized.Input.buy.capitalized
        case .sell: Localized.Input.sell.capitalized
        }
    }
}
