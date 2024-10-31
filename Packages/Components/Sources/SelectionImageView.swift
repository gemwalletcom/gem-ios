// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct SelectionImageView: View {
    public init() {}

    public var body: some View {
        ZStack {
            Images.Wallets.selected
                .resizable()
                .scaledToFit()
                .frame(
                    width: Sizing.list.selected.image,
                    height: Sizing.list.selected.image
                )
        }
        .frame(width: Sizing.list.image)
    }
}

// MARK: - Previews

#Preview {
    SelectionImageView()
}
