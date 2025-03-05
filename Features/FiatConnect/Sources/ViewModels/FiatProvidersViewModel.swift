// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components

public struct FiatProvidersViewModel: SelectableListAdoptable {
    public typealias Item = FiatQuoteViewModel
    public let state: StateViewType<[FiatQuoteViewModel]>
    public var selectedItems: Set<FiatQuoteViewModel>
    public let isMultiSelectionEnabled: Bool
    
    public init(
        state: StateViewType<[FiatQuoteViewModel]>,
        selectedItems: [FiatQuoteViewModel],
        isMultiSelectionEnabled: Bool
    ) {
        self.state = state
        self.selectedItems = Set(selectedItems)
        self.isMultiSelectionEnabled = isMultiSelectionEnabled
    }
}

extension FiatProvidersViewModel: SelectableListNavigationAdoptable {
    public var title: String { Localized.Buy.Providers.title }
    public var doneTitle: String { Localized.Common.done }
}
