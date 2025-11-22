// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components

@Observable
final class FiatOperationContext {
    var quotesState: StateViewType<[FiatQuote]> = .loading
    var selectedQuote: FiatQuote?
    var fetchTask: Task<Void, Never>?
    var amount: String

    init(defaultAmount: Int = 50) {
        self.amount = String(defaultAmount)
    }
}
