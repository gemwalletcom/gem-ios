// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

public enum ContextMenuItemType {
    case copy(title: String? = nil, value: String, onCopy: StringAction = nil)
    case pin(isPinned: Bool, onPin: VoidAction)
    case hide(VoidAction)
    case delete(VoidAction)
    case url(title: String, url: URL)
    case custom(
        title: String,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: VoidAction
    )
}
