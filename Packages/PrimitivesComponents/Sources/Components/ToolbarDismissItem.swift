// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization
import Style
import Components

public struct ToolbarDismissItem: ToolbarContent {
    @Environment(\.dismiss) private var dismiss

    public enum ButtonType {
        case cancel
        case done
        case close
        case custom(String)

        var localized: String {
            switch self {
            case .cancel: Localized.Common.cancel
            case .done: Localized.Common.done
            case .close: ""
            case .custom(let title): title
            }
        }
    }

    let type: ButtonType
    let placement: ToolbarItemPlacement

    public init(
        type: ButtonType,
        placement: ToolbarItemPlacement
    ) {
        self.type = type
        self.placement = placement
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            switch type {
            case .close:
                Button("", systemImage: SystemImage.xmark, action: { dismiss() })
            case .cancel, .done, .custom:
                Button(type.localized, action: { dismiss() })
                    .bold()
            }
        }
    }
}
