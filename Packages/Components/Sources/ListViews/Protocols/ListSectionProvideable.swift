// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol ItemModelProvidable {
    associatedtype ItemModel
    var itemModel: ItemModel { get }
}

@MainActor
public protocol ListSectionProvideable: Sendable {
    associatedtype Item: Identifiable & Sendable
    associatedtype ItemModel
    
    var sections: [ListSection<Item>] { get }
    func itemModel(for item: Item) -> ItemModel
}
