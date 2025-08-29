// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization

public struct ToolbarDismissItem: ToolbarContent {
    @Environment(\.dismiss) private var dismiss

    public enum Title {
        case cancel
        case done
        case custom(String)
        
        var localized: String {
            switch self {
            case .cancel: Localized.Common.cancel
            case .done: Localized.Common.done
            case .custom(let title): title
            }
        }
    }

    let title: Title
    let placement: ToolbarItemPlacement
    
    public init(
        title: Title,
        placement: ToolbarItemPlacement
    ) {
        self.title = title
        self.placement = placement
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(title.localized, action: { dismiss() })
                .bold()
        }
    }
}
