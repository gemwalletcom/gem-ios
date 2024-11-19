// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Localization
import Primitives

public struct SwapTokenEmptyView: View {
    
    let type: SelectAssetSwapType
    var onSelectAssetAction: ((SelectAssetSwapType) -> Void)
    
    public init(
        type: SelectAssetSwapType,
        onSelectAssetAction: @escaping (SelectAssetSwapType) -> Void
    ) {
        self.type = type
        self.onSelectAssetAction = onSelectAssetAction
    }
    
    public var body: some View {
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
