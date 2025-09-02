// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style

public struct TransactionStatusItemModel: ListItemViewable {
    public let title: String
    public let titleTagType: TitleTagType
    public let subtitle: String
    public let subtitleStyle: TextStyle
    public let infoAction: (@MainActor @Sendable () -> Void)?

    public init(
        title: String,
        titleTagType: TitleTagType,
        subtitle: String,
        subtitleStyle: TextStyle,
        infoAction: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.titleTagType = titleTagType
        self.subtitle = subtitle
        self.subtitleStyle = subtitleStyle
        self.infoAction = infoAction
    }

    public var listItemModel: ListItemType {
        .custom(
            ListItemConfiguration(
                title: title,
                titleTagType: titleTagType,
                subtitle: subtitle,
                subtitleStyle: subtitleStyle,
                infoAction: infoAction
            )
        )
    }
}
