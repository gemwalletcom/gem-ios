// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Style

public struct TransactionMemoItemModel: ListItemViewable {
    public let title: String
    public let subtitle: String
    
    public init(
        title: String,
        subtitle: String
    ) {
        self.title = title
        self.subtitle = subtitle
    }
    
    public var listItemModel: ListItemType {
        .basic(
            title: title,
            subtitle: subtitle
        )
    }
}