// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct AppIconViewModel: Identifiable, Hashable {
    public let icon: AppIcon
    public let isSelected: Bool

    public init(icon: AppIcon, isSelected: Bool) {
        self.icon = icon
        self.isSelected = isSelected
    }

    public var id: String { icon.id }

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
