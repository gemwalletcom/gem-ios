// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

public struct FiatQuoteTypeViewModel: Sendable {
    public let type: FiatQuoteType

    public init(type: FiatQuoteType) {
        self.type = type
    }
}

public extension FiatQuoteTypeViewModel {
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
        case .buy: Double(Int.random(in: Int(defaultAmount)..<Int(maxAmount))) // mobsf-ignore: ios_insecure_random_no_generator (UI suggestion only)
        case .sell: .none
        }
    }

    var title: String {
        switch type {
        case .buy: Localized.Wallet.buy
        case .sell: Localized.Wallet.sell
        }
    }
}
