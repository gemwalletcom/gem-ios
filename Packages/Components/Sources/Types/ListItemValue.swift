// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct ListItemValue<T> {
    public let title: String?
    public let subtitle: String?
    public let value: T

    public init(title: String? = .none, subtitle: String? = .none, value: T) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
    }
}

extension ListItemValue: Identifiable {
    public var id: String { title ?? subtitle ?? ""}
}

// MARK: - 

public struct ListItemValueSection<T: Identifiable> {
    public let section: String
    public let values: [ListItemValue<T>]

    public init(section: String, values: [ListItemValue<T>]) {
        self.section = section
        self.values = values
    }
}

extension ListItemValueSection: Identifiable {
    public var id: String { section }
}
