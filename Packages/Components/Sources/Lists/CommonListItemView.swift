// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct CommonListItemView: View {
    private let item: CommonListItem

    public init(item: CommonListItem) {
        self.item = item
    }

    public var body: some View {
        switch item {
        case let .detail(title, subtitle, image, _):
            ListItemImageView(
                title: title,
                subtitle: subtitle,
                assetImage: image
            )

        case let .value(label, value, extra, infoAction):
            ListItemView(
                title: label,
                subtitle: value,
                subtitleExtra: extra,
                placeholders: value == nil ? [.subtitle] : [],
                infoAction: infoAction
            )

        case let .error(title, error, action):
            ListItemErrorView(
                errorTitle: title,
                error: error,
                infoAction: action
            )

        case .loading:
            ListItemLoadingView(clearBackground: false)
        }
    }
}
