// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

@resultBuilder
enum ActionMenuBuilder {
    static func buildBlock(
        _ components: ActionMenuItemType...
    ) -> [ActionMenuItemType] { components }
}

public struct ActionMenu<Label: View>: View {
    private let items: [ActionMenuItemType]
    private let label: Label

    public init(
        items: [ActionMenuItemType],
        @ViewBuilder label: () -> Label
    ) {
        self.items = items
        self.label = label()
    }

    public init(
        @ActionMenuBuilder items: () -> [ActionMenuItemType],
        @ViewBuilder label: () -> Label
    ) {
        self.init(items: items(), label: label)
    }

    public var body: some View {
        Menu {
            ForEach(items) { ActionMenuItemView(item: $0) }
        } label: {
            label
        }
    }
}
