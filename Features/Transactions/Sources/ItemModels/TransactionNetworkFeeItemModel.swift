// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Style

public struct TransactionNetworkFeeItemModel: ListItemViewable {
    public let title: String
    public let subtitle: String
    public let subtitleExtra: String?
    public let infoAction: (@MainActor @Sendable () -> Void)?

    public init(
        title: String,
        subtitle: String,
        subtitleExtra: String? = nil,
        infoAction: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.subtitleExtra = subtitleExtra
        self.infoAction = infoAction
    }
    
    public var listItemModel: ListItemType {
        .custom(
            ListItemConfiguration(
                title: title,
                subtitle: subtitle,
                subtitleExtra: subtitleExtra,
                infoAction: infoAction
            )
        )
    }
}
