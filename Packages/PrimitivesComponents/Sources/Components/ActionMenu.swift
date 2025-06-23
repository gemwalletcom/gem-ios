// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

@resultBuilder
public enum ActionMenuBuilder {
    public static func buildBlock(
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
            ForEach(items) { build($0) }
        } label: {
            label
        }
    }

    @ViewBuilder
    private func build(_ item: ActionMenuItemType) -> some View {
        switch item {
        case let .button(title, systemImage, role, action):
            ContextMenuItem(
                title: title,
                systemImage: systemImage,
                role: role,
                action: { action?() }
            )
        }
    }
}
