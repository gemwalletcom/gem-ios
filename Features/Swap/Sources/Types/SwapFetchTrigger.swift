// Copyright (c). Gem Wallet. All rights reserved.

import Components
import SwapService

struct SwapFetchTrigger: DebouncableTrigger {
    let input: SwapQuoteInput
    let isImmediate: Bool
}
