// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Style
import SwiftUI
import Components

public struct TransactionTypesSelectorViewModel: SelectableSheetViewable {
    public var items: [FilterType] { state.value?.items ?? [] }
    
    public let selectionType: SelectionType
    public let state: StateViewType<SelectableListType<FilterType>>

    public var selectedItems: Set<FilterType>

    public init(
        state: StateViewType<SelectableListType<FilterType>>,
        selectedItems: [FilterType],
        selectionType: SelectionType
    ) {
        self.selectionType = selectionType
        self.state = state
        self.selectedItems = Set(selectedItems)
    }

    public var isSearchable: Bool { false }

    public var title: String { Localized.Filter.types }
    public var cancelButtonTitle: String { Localized.Common.cancel }
    public var clearButtonTitle: String { Localized.Filter.clear }
    public var doneButtonTitle: String { Localized.Common.done }
    public var emptyCotentModel: (any EmptyContentViewable)? { .none }
    public var confirmButtonTitle: String { Localized.Transfer.confirm }
}

