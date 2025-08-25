// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import PrimitivesComponents
import Swap

public enum TransferSectionType: Identifiable {
    case main
    case fee
    case error

    public var id: Self { self }
}

public struct TransferSection: ListSectionRepresentable {
    public let type: TransferSectionType
    public let items: [TransferListItem]

    public init(type: TransferSectionType, items: [TransferListItem]) {
        self.type = type
        self.items = items
    }

    public var id: TransferSectionType.ID { type.id }
}

// MARK: - Section Factory

public extension TransferSection {
    static func main(_ items: [TransferListItem]) -> Self? {
        items.isEmpty ? nil : Self(type: .main, items: items)
    }
    
    static func fee(_ items: [TransferListItem]) -> Self? {
        items.isEmpty ? nil : Self(type: .fee, items: items)
    }
    
    static func error(_ items: [TransferListItem]) -> Self? {
        items.isEmpty ? nil : Self(type: .error, items: items)
    }
}

public enum TransferListItem: ListItemRepresentable {
    case app
    case sender
    case network
    case address
    case memo
    case swapDetails

    case fee

    case error
    
    public var id: Self {
        self
    }
}

// MARK: - Filtering

public extension Array where Element == TransferSection? {
    func filterItems(_ predicate: (TransferListItem) -> Bool) -> [TransferSection?] {
        map { section in
            guard let section = section else { return nil }
            let filteredItems = section.items.filter(predicate)
            return filteredItems.isEmpty ? nil : TransferSection(type: section.type, items: filteredItems)
        }
    }
}

