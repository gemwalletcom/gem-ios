// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

extension Wallet {
    var keystoreId: String {
        externalId ?? id
    }
}
