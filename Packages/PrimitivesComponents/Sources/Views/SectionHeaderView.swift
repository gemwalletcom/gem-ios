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
        if let action {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var content: some View {
        HStack {
            if let image {
                image
            }
            Text(title)
            if action != nil {
                Images.System.chevronRight
            }
        }
        .bold()
    }
}
