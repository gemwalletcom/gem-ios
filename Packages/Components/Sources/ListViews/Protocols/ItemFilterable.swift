// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public protocol ItemFilterable {
    associatedtype Item: Hashable & Identifiable
    var items: [Item] { get }
    func filter(_ item: Item, query: String) -> Bool

    var emptyCotentModel: (any EmptyContentViewable)? { get }
}

public extension ItemFilterable {
    func filter(_ item: Item, query: String) -> Bool {
        fatalError("not implemented")
    }
}
