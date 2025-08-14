// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol ListItemRepresentable: Identifiable {}
public protocol ListSectionRepresentable: Identifiable {
    associatedtype Item: ListItemRepresentable
    var items: [Item] { get }
}
