// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization
import Components

public struct TransactionDateViewModel: Sendable {
    private let date: Date

    public init(date: Date) {
        self.date = date
    }

    public var itemModel: TransactionItemModel {
        .listItem(
            .text(
                title: Localized.Transaction.date,
                subtitle: formattedDate
            )
        )
    }
}

// MARK: - Private

extension TransactionDateViewModel {
    private var formattedDate: String {
        TransactionDateFormatter(date: date).row
    }
}
