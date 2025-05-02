// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Style
import SwiftUI
import Components

public struct NetworkSelectorViewModel: SelectableSheetViewable {
    public var selectionType: SelectionType
    public var isSearchable: Bool { true }
    public let state: StateViewType<SelectableListType<Chain>>

    public var selectedItems: Set<Chain>

    public init(
        state: StateViewType<SelectableListType<Chain>>,
        selectedItems: [Chain],
        selectionType: SelectionType
    ) {
        self.selectionType = selectionType
        self.state = state
        self.selectedItems = Set(selectedItems)
    }

    public var title: String { Localized.Settings.Networks.title }
    public var cancelButtonTitle: String { Localized.Common.cancel }
    public var clearButtonTitle: String { Localized.Filter.clear }
    public var doneButtonTitle: String { Localized.Common.done }
    public var noResultsTitle: String? { Localized.Common.noResultsFound }
    public var confirmButtonTitle: String { Localized.Transfer.confirm }
}

extension NetworkSelectorViewModel: ItemFilterable {

    public var emptyCotentModel: (any EmptyContentViewable)? {
        EmptyContentTypeViewModel(type: .search(type: EmptyContentType.SearchType.networks))
    }
    
    public var items: [Chain] {
        state.value?.items ?? []
    }

    public func filter(_ chain: Chain, query: String) -> Bool {
        chain.asset.name.localizedCaseInsensitiveContains(query) ||
        chain.asset.symbol.localizedCaseInsensitiveContains(query) ||
        chain.rawValue.localizedCaseInsensitiveContains(query)
    }
}
