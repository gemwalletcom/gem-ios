// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol ItemModelProvidable<ItemModel> {
    associatedtype ItemModel
    var itemModel: ItemModel { get }
}

@MainActor
public protocol ListSectionProvideable: Sendable {
    associatedtype Item: Identifiable & Sendable
    associatedtype ItemModel
    
    var sections: [ListSection<Item>] { get }
    func itemModel(for type: Item) -> any ItemModelProvidable<ItemModel>
}

public extension ListSectionProvideable {
    func item(for type: Item) -> ItemModel {
        itemModel(for: type).itemModel
    }
}
