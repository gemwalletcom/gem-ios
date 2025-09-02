// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Style
import Localization

public struct TransactionDateItemModel: ListItemViewable {
    private let date: Date
    
    public init(date: Date) {
        self.date = date
    }
    
    public var listItemModel: ListItemType {
        .basic(
            title: Localized.Transaction.date,
            subtitle: TransactionDateFormatter(date: date).row
        )
    }
}