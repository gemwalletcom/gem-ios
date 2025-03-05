// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Style
import SwiftUI
import Components

public struct TransactionTypesSelectorViewModel: SelectableSheetViewable {
    public var items: [Primitives.TransactionType] { state.value.or([]) }
    
    public let isMultiSelectionEnabled: Bool
    public let state: StateViewType<[TransactionType]>

    public var selectedItems: Set<TransactionType>

    public init(state: StateViewType<[TransactionType]>, selectedItems: [TransactionType], isMultiSelectionEnabled: Bool) {
        self.isMultiSelectionEnabled = isMultiSelectionEnabled
        self.state = state
        self.selectedItems = Set(selectedItems)
    }

    public var isSearchable: Bool { false }

    public var title: String { Localized.Filter.types }
    public var cancelButtonTitle: String { Localized.Common.cancel }
    public var clearButtonTitle: String { Localized.Filter.clear }
    public var doneButtonTitle: String { Localized.Common.done }
    public var noResultsTitle: String? { .none }
    public var noResultsImage: Image? { .none }
}

