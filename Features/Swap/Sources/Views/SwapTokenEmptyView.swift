// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization
import Primitives

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
                Text(Localized.Assets.selectAsset)
                    .padding(.horizontal, .extraSmall)
                    .padding(.vertical, .medium)
                SwapChevronView()
            }
        }
    }
}
