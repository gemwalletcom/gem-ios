// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components

public enum TransactionSectionType: Identifiable, Equatable {
    case swapAction
    case details
    case explorer

    public var id: Self { self }
}

public struct TransactionSection: ListSectionRepresentable, Equatable {
    public let type: TransactionSectionType
    public let items: [TransactionListItem]

    public var id: TransactionSectionType.ID { type.id }
}

public enum TransactionListItem: ListItemRepresentable, Equatable {
    case date
    case status
    case sender
    case recipient
    case validator
    case contract
    case memo
    case fee
    case network
    case provider

    case explorerLink

    case swapAgainButton

    public var id: Self {
        self
    }
}

// MARK: - Section Factory

public extension TransactionSection {
    static func swapAction(_ items: [TransactionListItem]) -> Self? {
        items.isEmpty ? nil : Self(type: .swapAction, items: items)
    }

    static func details(_ items: [TransactionListItem]) -> Self? {
        items.isEmpty ? nil : Self(type: .details, items: items)
    }

    static func explorer(_ items: [TransactionListItem]) -> Self? {
        items.isEmpty ? nil : Self(type: .explorer, items: items)
    }
}

// MARK: - Filtering

public extension Array where Element == TransactionSection? {
    func filterItems(_ predicate: (TransactionListItem) -> Bool) -> [TransactionSection?] {
        map { section in
            guard let section = section else { return nil }
            let filteredItems = section.items.filter(predicate)
            return filteredItems.isEmpty ? nil : TransactionSection(type: section.type, items: filteredItems)
        }
    }
}
