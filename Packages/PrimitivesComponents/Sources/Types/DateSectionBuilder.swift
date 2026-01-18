// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components

public struct DateSectionBuilder<Item, T: Sendable & Identifiable> {
    private let items: [Item]
    private let dateKeyPath: KeyPath<Item, Date>
    private let transform: (Item) -> T

    public init(
        items: [Item],
        dateKeyPath: KeyPath<Item, Date>,
        transform: @escaping (Item) -> T
    ) {
        self.items = items
        self.dateKeyPath = dateKeyPath
        self.transform = transform
    }

    public func build() -> [ListSection<T>] {
        Dictionary(grouping: items) { Calendar.current.startOfDay(for: $0[keyPath: dateKeyPath]) }
            .sorted { $0.key > $1.key }
            .map { date, items in
                ListSection(
                    id: date.ISO8601Format(),
                    title: TransactionDateFormatter(date: date).section,
                    image: nil,
                    values: items.map(transform)
                )
            }
    }
}

public extension DateSectionBuilder where Item == T {
    init(items: [Item], dateKeyPath: KeyPath<Item, Date>) {
        self.init(items: items, dateKeyPath: dateKeyPath, transform: { $0 })
    }
}
