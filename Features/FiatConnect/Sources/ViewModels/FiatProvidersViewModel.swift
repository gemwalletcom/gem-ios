// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components

public struct FiatProvidersViewModel: SelectableListAdoptable {
    public typealias Item = FiatQuoteViewModel
    public var items: [FiatQuoteViewModel]
    public var selectedItems: Set<FiatQuoteViewModel>
    public var isMultiSelectionEnabled: Bool
    
    public init(
        items: [FiatQuoteViewModel],
        selectedItems: [FiatQuoteViewModel],
        isMultiSelectionEnabled: Bool
    ) {
        self.items = items
        self.selectedItems = Set(selectedItems)
        self.isMultiSelectionEnabled = isMultiSelectionEnabled
    }
}
