// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Localization

struct SwapTokenEmptyView: View {
    
    let type: SelectAssetSwapType
    var onSelectAssetAction: ((SelectAssetSwapType) -> Void)
    
    var body: some View {
        Button(role: .none) {
            onSelectAssetAction(type)
        } label: {
            HStack {
                Text(Localized.Assets.selectAsset)
                    .padding(.horizontal, Spacing.extraSmall)
                    .padding(.vertical, Spacing.medium)
                SwapChevronView()
            }
        }
    }
}
