// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

public struct EmptyContentView: View {
    public let model: EmptyContentTypeViewModel

    public init(model: EmptyContentTypeViewModel) {
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

#Preview {
    EmptyContentView(
        model: .init(
            type: .activity(
                receive: {},
                buy: {})
        )
    )
}
