// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct SearchableListView<Item: Identifiable, Content: View, EmptyContent: View>: View {
    let items: [Item]
    let filter: (Item, String) -> Bool
    let content: (Item) -> Content
    let emptyContent: () -> EmptyContent

    @State private var searchQuery = ""

    public init(
        items: [Item],
        filter: @escaping (Item, String) -> Bool,
        @ViewBuilder content: @escaping (Item) -> Content,
        @ViewBuilder emptyContent: @escaping () -> EmptyContent
    ) {
        self.items = items
        self.filter = filter
        self.content = content
        self.emptyContent = emptyContent
    }

    public var body: some View {
        VStack {
            List {
                ForEach(filteredItems) { item in
                    content(item)
                }
            }
            .overlay {
                if filteredItems.isEmpty {
                    emptyContent()
                }
            }
            .searchable(
                text: $searchQuery,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .autocorrectionDisabled(true)
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

// MARK: - Private

extension SearchableListView {
    private var filteredItems: [Item] {
        guard !searchQuery.isEmpty else { return items }
        return items.filter { filter($0, searchQuery) }
    }
}
