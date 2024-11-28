// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public protocol ItemFilterable {
    associatedtype Item: Hashable & Identifiable
    var items: [Item] { get }
    func filter(_ item: Item, query: String) -> Bool

    var noResultsTitle: String? { get }
    var noResultsImage: Image? { get }
}

public extension ItemFilterable {
    func filter(_ item: Item, query: String) -> Bool {
        fatalError("not implemented")
    }
    var noResultsTitle: String? { .none }
    var noResultsImage: Image? { .none }
}
