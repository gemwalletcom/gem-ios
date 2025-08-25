// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public enum ContextMenuItemType {
    case copy(title: String? = nil, value: String, onCopy: ((String) -> Void)? = nil)
    case pin(isPinned: Bool, onPin: (() -> Void)?)
    case hide((() -> Void)?)
    case delete((() -> Void)?)
    case url(title: String, onOpen: (() -> Void)?)
    case custom(
        title: String,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: (() -> Void)?
    )
}
