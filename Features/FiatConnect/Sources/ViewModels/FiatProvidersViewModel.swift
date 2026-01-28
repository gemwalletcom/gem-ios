// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components

struct FiatProvidersViewModel: SelectableListAdoptable {
    public typealias Item = FiatQuoteViewModel
    let state: StateViewType<SelectableListType<FiatQuoteViewModel>>
    var selectedItems: Set<FiatQuoteViewModel>
    let selectionType: SelectionType
    
    init(
        state: StateViewType<SelectableListType<FiatQuoteViewModel>>,
        selectedItems: [FiatQuoteViewModel],
        selectionType: SelectionType
    ) {
        self.state = state
        self.selectedItems = Set(selectedItems)
        self.selectionType = selectionType
    }
}

extension FiatProvidersViewModel: SelectableListNavigationAdoptable {
    var title: String { Localized.Buy.Providers.title }
    var doneTitle: String { Localized.Common.done }
}
