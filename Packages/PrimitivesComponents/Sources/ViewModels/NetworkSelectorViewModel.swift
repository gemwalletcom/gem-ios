// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Style
import SwiftUI
import Components

public struct NetworkSelectorViewModel: SelectableSheetViewable {
    public var isSearchable: Bool { true }
    public let isMultiSelectionEnabled: Bool
    public let items: [Chain]

    public var selectedItems: Set<Chain>

    public init(items: [Chain], selectedItems: [Chain], isMultiSelectionEnabled: Bool) {
        self.isMultiSelectionEnabled = isMultiSelectionEnabled
        self.items = items
        self.selectedItems = Set(selectedItems)
    }

    public var title: String { Localized.Settings.Networks.title }
    public var cancelButtonTitle: String { Localized.Common.cancel }
    public var clearButtonTitle: String { Localized.Filter.clear }
    public var doneButtonTitle: String { Localized.Common.done }
    public var noResultsTitle: String? { Localized.Common.noResultsFound }
    public var noResultsImage: Image? { Images.System.searchNoResults }
}

extension NetworkSelectorViewModel: ItemFilterable {
    public func filter(_ chain: Chain, query: String) -> Bool {
        chain.asset.name.localizedCaseInsensitiveContains(query) ||
        chain.asset.symbol.localizedCaseInsensitiveContains(query) ||
        chain.rawValue.localizedCaseInsensitiveContains(query)
    }
}
