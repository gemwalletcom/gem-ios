// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Validators
import BigInt
import Formatters

protocol FiatOperation: Sendable {
    var defaultAmount: Int { get }
    var emptyAmountTitle: String { get }

    func fetch(amount: Double) async throws -> [FiatQuote]

    func validators(
        availableBalance: BigInt,
        selectedQuote: FiatQuote?
    ) -> [any TextValidator]
}
