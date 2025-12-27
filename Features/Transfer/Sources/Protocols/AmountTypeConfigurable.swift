// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol AmountTypeConfigurable<Item, ItemViewModel> {
    associatedtype Item: Hashable & Sendable
    associatedtype ItemViewModel

    var items: [Item] { get }
    var defaultItem: Item? { get }
    var selectedItem: Item? { get set }
    var selectedItemViewModel: ItemViewModel? { get }
    var isSelectionEnabled: Bool { get }
    var selectionTitle: String { get }
}
