// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public protocol SelectableListAdoptable {
    associatedtype Item: Hashable & Identifiable
    var isMultiSelectionEnabled: Bool { get }

    var items: [Item] { get }
    var selectedItems: Set<Item> { get set }

    init(items: [Item], selectedItems: [Item], isMultiSelectionEnabled: Bool)
    init(items: [Item])

    mutating func reset()
    mutating func toggle(item: Item)
}

public extension SelectableListAdoptable {
    init(items: [Item]) {
        self.init(items: items, selectedItems: [], isMultiSelectionEnabled: false)
    }

    var shouldResetOnToggle: Bool {
        !isMultiSelectionEnabled && !selectedItems.isEmpty
    }

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
