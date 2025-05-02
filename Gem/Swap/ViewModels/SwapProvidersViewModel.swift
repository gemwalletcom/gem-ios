// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone
import Components
import Localization

public struct SwapProvidersViewModel: SelectableListAdoptable {
    public typealias Item = SwapProviderItem
    public var state: StateViewType<SelectableListType<SwapProviderItem>>
    public var selectedItems: Set<SwapProviderItem>
    public var selectionType: SelectionType
    public var emptyStateTitle: String? { Localized.Common.notAvailable }
    public var errorTitle: String? { Localized.Errors.errorOccured }
    
    public init(
        state: StateViewType<SelectableListType<Item>>,
        selectedItems: [SwapProviderItem],
        selectionType: SelectionType
    ) {
        self.state = state
        self.selectedItems = Set(selectedItems)
        self.selectionType = selectionType
    }
}

extension SwapProvidersViewModel: SelectableListNavigationAdoptable {
    public var title: String { Localized.Buy.Providers.title }
    public var doneTitle: String { Localized.Common.done }
}
