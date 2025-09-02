// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization

public struct TransactionDateViewModel: Sendable {
    private let date: Date
    
    public init(date: Date) {
        self.date = date
    }
    
    private var formattedDate: String {
        TransactionDateFormatter(date: date).row
    }
    
    public var itemModel: TransactionDateItemModel {
        TransactionDateItemModel(
            title: Localized.Transaction.date,
            subtitle: formattedDate
        )
    }
}