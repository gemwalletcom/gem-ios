// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Settings

struct AddTokenInput {
    let availableChains: [Chain]

    var chain: Chain?
    var address: String?

    init(availableChains: [Chain]) {
        self.availableChains = availableChains
        // set default chain
        self.chain = availableChains.first
    }
}
