// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum TabItem: Identifiable {
    case wallet
    case collections
    case activity
    case settings

    var id: Self { self }
}
