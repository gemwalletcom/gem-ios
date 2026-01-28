// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Localization

struct SwapProvidersViewModel: SelectableListAdoptable {
    public typealias Item = SwapProviderItem

    var state: StateViewType<SelectableListType<SwapProviderItem>>
    var selectedItems: Set<SwapProviderItem>
    var selectionType: SelectionType
    
    init(
        state: StateViewType<SelectableListType<Item>>,
        selectedItems: [SwapProviderItem],
        selectionType: SelectionType
    ) {
        self.state = state
        self.selectedItems = Set(selectedItems)
        self.selectionType = selectionType
    }

    var emptyStateTitle: String? { Localized.Common.notAvailable }
    var errorTitle: String? { Localized.Errors.errorOccured }
}

extension SwapProvidersViewModel: SelectableListNavigationAdoptable {
    var title: String { Localized.Buy.Providers.title }
    var doneTitle: String { Localized.Common.done }
}
