// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Validators
import BigInt
import Formatters

protocol FiatOperationStrategy: Sendable {
    var type: FiatQuoteType { get }

    func fetch(amount: Double) async throws -> [FiatQuote]

    func validators(
        availableBalance: BigInt,
        selectedQuote: FiatQuote?
    ) -> [any TextValidator]
}
