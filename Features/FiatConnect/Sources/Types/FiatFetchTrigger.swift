// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

struct FiatFetchTrigger: Equatable, Sendable {
    static let debounceInterval: Duration = .milliseconds(250)

    let type: FiatQuoteType
    let amount: String
    let immediate: Bool
}
