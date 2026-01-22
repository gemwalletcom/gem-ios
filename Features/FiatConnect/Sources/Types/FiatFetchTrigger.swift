// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Components

struct FiatFetchTrigger: DebouncableTrigger {
    let type: FiatQuoteType
    let amount: String
    let isImmediate: Bool
}
