// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public enum SelectableListType<T> {
    case plain([T])
    case section([ListSection<T>])
    
    public var items: [T] {
        switch self {
        case .plain(let items):
            items
        case .section(let sections):
            sections.map { $0.values }.reduce([], +)
        }
    }
}

public enum SelectionType {
    case multiSelection
    case navigationLink
    case checkmark
}

public protocol SelectableListAdoptable {
    associatedtype Item: Hashable & Identifiable
    var selectionType: SelectionType { get }

    var state: StateViewType<SelectableListType<Item>> { get }
    var selectedItems: Set<Item> { get set }
    
    var emptyStateTitle: String? { get }
    var errorTitle: String? { get }

    init(state: StateViewType<SelectableListType<Item>>, selectedItems: [Item], selectionType: SelectionType)
    init(state: StateViewType<SelectableListType<Item>>)

    mutating func reset()
    mutating func toggle(item: Item)
}

public extension SelectableListAdoptable {
    init(state: StateViewType<SelectableListType<Item>>) {
        self.init(state: state, selectedItems: [], selectionType: .navigationLink)
    }

    var shouldResetOnToggle: Bool {
        switch selectionType {
        case .multiSelection: false
        case .navigationLink, .checkmark: true
        }
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
