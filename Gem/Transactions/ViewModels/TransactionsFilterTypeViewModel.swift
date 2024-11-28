// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Foundation
import Localization
import Style

struct TransactionsFilterTypeViewModel: FilterTypeRepresentable {
    private let type: TransactionsFilterType

    init(type: TransactionsFilterType) {
        self.type = type
    }

    var value: String {
        switch type {
        case .allTypes:
            Localized.Common.all
        case let .type(type):
            TransactionTypeViewModel(type: type).title
        case let .types(selected):
            "\(selected.count)"
        }
    }

    var title: String { Localized.Filter.types }
    var image: Image { Images.System.textPageFill }
}
