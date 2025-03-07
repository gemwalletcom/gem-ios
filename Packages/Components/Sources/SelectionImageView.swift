// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct SelectionImageView: View {
    public init() {}

    public var body: some View {
        Images.Wallets.selected
            .resizable()
            .scaledToFit()
            .frame(
                width: .list.selected.image,
                height: .list.selected.image
            )
    }
}

// MARK: - Previews

#Preview {
    SelectionImageView()
}
