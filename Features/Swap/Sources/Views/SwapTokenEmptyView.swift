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
                Text(Localized.Assets.selectAsset)
                    .textStyle(
                        TextStyle(font: .body, color: .primary, fontWeight: .medium)
                    )
                    .padding(.horizontal, .extraSmall)
                    .padding(.vertical, .medium)
                    .lineLimit(1)
                SwapChevronView()
            }
        }
    }
}
