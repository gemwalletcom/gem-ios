// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public enum ListItemType {
    case text(title: String, subtitle: String? = nil)
    case custom(ListItemConfiguration)
    case empty
}

