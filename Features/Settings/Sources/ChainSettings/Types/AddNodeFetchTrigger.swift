// Copyright (c). Gem Wallet. All rights reserved.

import Components

struct AddNodeFetchTrigger: DebouncableTrigger {
    let url: String
    let isImmediate: Bool
}
