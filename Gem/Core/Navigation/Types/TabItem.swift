// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum TabItem: Identifiable, CaseIterable {
    case wallet
    case collections
    case swap
    case activity
    case settings

    var id: Self { self }
}
