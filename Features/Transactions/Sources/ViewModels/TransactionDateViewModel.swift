// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PrimitivesComponents
import Localization
import Components

struct TransactionDateViewModel: Sendable {
    private let date: Date

    init(date: Date) {
        self.date = date
    }
}

// MARK: - ItemModelProvidable

extension TransactionDateViewModel: ItemModelProvidable {
    var itemModel: TransactionItemModel {
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
