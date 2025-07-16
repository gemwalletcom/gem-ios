// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization
import Primitives
import Components

struct SwapTokenEmptyView: View {
    private let onSelectAssetAction: (() -> Void)

    init(onSelectAssetAction: @escaping () -> Void) {
        self.onSelectAssetAction = onSelectAssetAction
    }

    var body: some View {
        Button(role: .none) {
            onSelectAssetAction()
        } label: {
            HStack {
                Spacer()
                AssetImageView(assetImage: .image(Images.Placeholders.addAsset))
                Text(Localized.Common.select)
                    .textStyle(
                        TextStyle(font: .body, color: .primary, fontWeight: .semibold)
                    )
                    .padding(.horizontal, .extraSmall)
                    .padding(.vertical, .medium)
                    .lineLimit(1)
                SwapChevronView()
            }
        }
    }
}
