// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct AdaptiveActionMenu<Label: View>: View {
    @State private var isPresentingConfirmation = false

    private let items: [ActionMenuItemType]
    private let title: String?
    private let label: Label

    public init(
        title: String? = nil,
        items: [ActionMenuItemType],
        @ViewBuilder label: () -> Label
    ) {
        self.title = title
        self.items = items
        self.label = label()
    }

    public var body: some View {
        if isPad {
            ActionMenu(items: items) { label }
        } else {
            Button { isPresentingConfirmation = true } label: { label.disabled(true) }
                .confirmationDialog(
                    title ?? "",
                    isPresented: $isPresentingConfirmation,
                    titleVisibility: (title == nil) ? .hidden : .visible,
                    actions: {
                        ForEach(items) { ActionMenuItemView(item: $0) }
                    }
                )
        }
    }

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
}
