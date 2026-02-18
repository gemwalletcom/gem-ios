// Copyright (c). Gem Wallet. All rights reserved.

import Components

struct SwapFetchTrigger: DebouncableTrigger {
    let input: SwapQuoteInput
    let isImmediate: Bool
}
