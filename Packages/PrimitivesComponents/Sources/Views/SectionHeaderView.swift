// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Primitives

public struct SectionHeaderView: View {
    let title: String
    let image: Image?
    let actionTitle: String?
    let action: VoidAction

    public init(
        title: String,
        image: Image? = nil,
        actionTitle: String? = nil,
        action: VoidAction = nil
    ) {
        self.title = title
        self.image = image
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(spacing: Spacing.tiny) {
            if let image {
                image
            }
            Text(title)
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    HStack(spacing: Spacing.tiny) {
                        Text(actionTitle)
                        Images.System.chevronRight
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
