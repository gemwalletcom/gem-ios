// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct ListSectionView<Item: Identifiable & Sendable, Content: View>: View {
    private let sections: [ListSection<Item>]
    private let content: (Item) -> Content

    public init(
        sections: [ListSection<Item>],
        @ViewBuilder content: @escaping  (Item) -> Content
    ) {
        self.sections = sections
        self.content = content
    }
    
    public var body: some View {
        List {
            ForEach(sections) { section in
                let sectionContent = {
                    ForEach(section.values) { item in
                        content(item)
                    }
                }

                Section {
                    sectionContent()
                } header: {
                    if section.title == nil && section.image == nil {
                        EmptyView()
                    } else {
                        HStack {
                            if let image = section.image {
                                image
                            }
                            if let title = section.title {
                                Text(title)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - SectionedItemProvider Support

public extension ListSectionView {
    init<Provider: ListSectionProvideable>(
        provider: Provider,
        @ViewBuilder content: @escaping (Provider.ItemModel) -> Content
    ) where Item == Provider.Item {
        self.init(sections: provider.sections) { type in
            content(provider.item(for: type))
        }
    }
}
