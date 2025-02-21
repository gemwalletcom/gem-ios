// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone
import Components

public struct SwapProvidersViewModel: SelectableListAdoptable {
    public typealias Item = SwapProviderItem
    public var items: [SwapProviderItem]
    public var selectedItems: Set<SwapProviderItem>
    public var isMultiSelectionEnabled: Bool
    
    public init(
        items: [SwapProviderItem],
        selectedItems: [SwapProviderItem],
        isMultiSelectionEnabled: Bool
    ) {
        self.items = items
        self.selectedItems = Set(selectedItems)
        self.isMultiSelectionEnabled = isMultiSelectionEnabled
    }
}
