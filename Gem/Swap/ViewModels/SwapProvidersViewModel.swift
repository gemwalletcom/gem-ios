// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone
import Components
import Localization

public struct SwapProvidersViewModel: SelectableListAdoptable {
    public typealias Item = SwapProviderItem
    public var state: StateViewType<[SwapProviderItem]>
    public var selectedItems: Set<SwapProviderItem>
    public var isMultiSelectionEnabled: Bool
    public var emptyStateTitle: String? { Localized.Common.notAvailable }
    public var errorTitle: String? { Localized.Errors.errorOccured }
    
    public init(
        state: StateViewType<[Item]>,
        selectedItems: [SwapProviderItem],
        isMultiSelectionEnabled: Bool
    ) {
        self.state = state
        self.selectedItems = Set(selectedItems)
        self.isMultiSelectionEnabled = isMultiSelectionEnabled
    }
}
