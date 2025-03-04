// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
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
                HStack(spacing: .small) {
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
