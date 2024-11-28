// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Style
import SwiftUI
import Components

struct TransactionTypesSelectorViewModel: SelectableSheetViewable {

    let isMultiSelectionEnabled: Bool
    let items: [TransactionType]

    var selectedItems: Set<TransactionType>

    init(items: [TransactionType], selectedItems: [TransactionType], isMultiSelectionEnabled: Bool) {
        self.isMultiSelectionEnabled = isMultiSelectionEnabled
        self.items = items
        self.selectedItems = Set(selectedItems)
    }

    var isSearchable: Bool { false }

    var title: String { Localized.Filter.types }
    var cancelButtonTitle: String { Localized.Common.cancel }
    var clearButtonTitle: String { Localized.Filter.clear }
    var doneButtonTitle: String { Localized.Common.done }
    var noResultsTitle: String? { .none }
    var noResultsImage: Image? { .none }
}

