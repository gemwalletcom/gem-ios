// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style

public struct EmptyContentView: View {
    public let model: any EmptyContentViewable

    public init(model: any EmptyContentViewable) {
        self.model = model
    }

    public var body: some View {
        StateEmptyView(
            title: model.title,
            description: model.description,
            image: model.image,
            buttons: {
                HStack(spacing: Spacing.small) {
                    ForEach(model.buttons) { button in
                        if let action = button.action {
                            Button(button.title) {
                                action()
                            }
                            .buttonStyle(
                                .amount()
                            )
                        }
                    }
                }
                .fixedSize()
            }
        )
    }
}

// simple wrapper to store inside a list as section
public struct EmptyContentSection: View {
    public let model: any EmptyContentViewable
    public let botomPadding: CGFloat

    public init(
        model: any EmptyContentViewable,
        botomPadding: CGFloat = Spacing.large
    ) {
        self.model = model
        self.botomPadding = botomPadding
    }

    public var body: some View {
        Section { } header: {
            EmptyContentView(model: model)
                .padding(.top, Spacing.large)
        }
        .frame(maxWidth: .infinity)
        .textCase(nil)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }
}
