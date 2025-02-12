// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Foundation
import Localization
import Style
import PrimitivesComponents

public struct TransactionsFilterTypeViewModel: FilterTypeRepresentable {
    private let type: TransactionsFilterType

    public init(type: TransactionsFilterType) {
        self.type = type
    }

    public var value: String {
        switch type {
        case .allTypes:
            Localized.Common.all
        case let .type(type):
            TransactionTypeViewModel(type: type).title
        case let .types(selected):
            "\(selected.count)"
        }
    }

    public var title: String { Localized.Filter.types }
    public var image: Image { Images.System.textPageFill }
}
