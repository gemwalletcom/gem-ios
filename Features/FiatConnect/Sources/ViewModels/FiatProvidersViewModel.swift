// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components

public struct FiatProvidersViewModel: SelectableListAdoptable {
    public typealias Item = FiatQuoteViewModel
    public let state: StateViewType<SelectableListType<FiatQuoteViewModel>>
    public var selectedItems: Set<FiatQuoteViewModel>
    public let selectionType: SelectionType
    
    public init(
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
    public var title: String { Localized.Buy.Providers.title }
    public var doneTitle: String { Localized.Common.done }
}
