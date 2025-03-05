// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public protocol SelectableListAdoptable {
    associatedtype Item: Hashable & Identifiable
    var isMultiSelectionEnabled: Bool { get }

    var state: StateViewType<[Item]> { get }
    var selectedItems: Set<Item> { get set }
    
    var emptyStateTitle: String? { get }
    var errorTitle: String? { get }

    init(state: StateViewType<[Item]>, selectedItems: [Item], isMultiSelectionEnabled: Bool)
    init(state: StateViewType<[Item]>)

    mutating func reset()
    mutating func toggle(item: Item)
}

public extension SelectableListAdoptable {
    init(state: StateViewType<[Item]>) {
        self.init(state: state, selectedItems: [], isMultiSelectionEnabled: false)
    }

    var shouldResetOnToggle: Bool {
        !isMultiSelectionEnabled && !selectedItems.isEmpty
    }
    
    var emptyStateTitle: String? { nil }
    var errorTitle: String? { nil }

    mutating func toggle(item: Item) {
        if shouldResetOnToggle {
            reset()
        }

        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }

    mutating func reset() {
        selectedItems = []
    }
}
