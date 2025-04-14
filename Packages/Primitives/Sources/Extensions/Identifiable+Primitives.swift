// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension Collection where Element: Identifiable {
    var ids: [Element.ID] {
        map(\.id)
    }
}
