// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Primitives

public struct SectionHeaderView: View {
    let title: String
    let image: Image?
    let action: VoidAction

    public init(
        title: String,
        image: Image? = nil,
        action: VoidAction = nil
    ) {
        self.title = title
        self.image = image
        self.action = action
    }

    public var body: some View {
        HStack(spacing: Spacing.tiny) {
            if let image {
                image
            }
            Text(title)
            if let action {
                Button(action: action) {
                    Images.System.chevronRight
                }
                .buttonStyle(.plain)
            }
        }
    }
}
