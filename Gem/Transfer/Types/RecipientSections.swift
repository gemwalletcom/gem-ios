// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct RecipientSections {
    let pinned: RecipientSection
    let wallets: RecipientSection
    let view: RecipientSection
}

struct RecipientSection {
    let title: String
    let items: [RecipientAddress]
}
