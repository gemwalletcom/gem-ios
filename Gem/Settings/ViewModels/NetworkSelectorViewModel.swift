// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Style
import SwiftUI
import Components

struct NetworkSelectorViewModel: SelectableSheetViewable {
    var isSearchable: Bool { true }
    let isMultiSelectionEnabled: Bool
    let items: [Chain]

    var selectedItems: Set<Chain>

    init(items: [Chain], selectedItems: [Chain], isMultiSelectionEnabled: Bool) {
        self.isMultiSelectionEnabled = isMultiSelectionEnabled
        self.items = items
        self.selectedItems = Set(selectedItems)
    }

    var title: String { Localized.Settings.Networks.title }
    var cancelButtonTitle: String { Localized.Common.cancel }
    var clearButtonTitle: String { Localized.Filter.clear }
    var doneButtonTitle: String { Localized.Common.done }
    var noResultsTitle: String? { Localized.Common.noResultsFound }
    var noResultsImage: Image? { Images.System.searchNoResults }
}

extension NetworkSelectorViewModel: ItemFilterable {
    func filter(_ chain: Chain, query: String) -> Bool {
        chain.asset.name.localizedCaseInsensitiveContains(query) ||
        chain.asset.symbol.localizedCaseInsensitiveContains(query) ||
        chain.rawValue.localizedCaseInsensitiveContains(query)
    }
}
