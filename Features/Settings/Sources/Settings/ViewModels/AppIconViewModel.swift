// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct AppIconViewModel: Identifiable, Hashable {
    let icon: AppIcon
    let isSelected: Bool

    init(icon: AppIcon, isSelected: Bool) {
        self.icon = icon
        self.isSelected = isSelected
    }

    var id: String { icon.id }

    var displayName: String {
        switch icon {
        case .primary: "Default"
        case .mono: "Mono"
        case .lava: "Lava"
        }
    }

    var image: Image {
        switch icon {
        case .primary: Images.AppIcons.primary
        case .mono: Images.AppIcons.mono
        case .lava: Images.AppIcons.lava
        }
    }
}
