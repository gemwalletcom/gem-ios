// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct ListView<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    public init(items: [Item], @ViewBuilder content: @escaping (Item) -> Content) {
        self.items = items
        self.content = content
    }

    public var body: some View {
        List(items) { item in
            content(item)
            .listRowInsets(.assetListRowInsets)
            .listSectionSpacing(.compact)
        }
    }
}
