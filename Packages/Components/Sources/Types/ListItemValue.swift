// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct ListItemValue<T: Identifiable> {
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
    public var id: T.ID { value.id }
}

// MARK: - 

public struct ListItemValueSection<T: Identifiable> {
    public let section: String
    public let image: Image?
    public let footer: String?
    public let values: [ListItemValue<T>]

    public init(
        section: String,
        image: Image? = .none,
        footer: String? = .none,
        values: [ListItemValue<T>]
    ) {
        self.section = section
        self.image = image
        self.footer = footer
        self.values = values
    }
}

extension ListItemValueSection: Identifiable {
    public var id: String { section }
}

public struct ListItemValueSectionList <Item: Identifiable, Content: View>: View {
    private let list: [ListItemValueSection<Item>]
    private let content: (Item) -> Content
    
    public init(
        list: [ListItemValueSection<Item>],
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.list = list
        self.content = content
    }
    
    public var body: some View {
        ForEach(list) { section in
            Section {
                ForEach(section.values) { alert in
                    content(alert.value)
                }
            } header: {
                if section.section.isEmpty {
                    EmptyView()
                } else {
                    Text(section.section)
                }
            } footer: {
                if let footer = section.footer, !section.values.isEmpty {
                    Text(footer)
                }
            }
            .listRowInsets(.assetListRowInsets)
        }
    }
}
