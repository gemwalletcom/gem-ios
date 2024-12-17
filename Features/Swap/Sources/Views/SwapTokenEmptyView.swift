// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Localization
import Primitives

public struct SwapTokenEmptyView: View {
    
    var onSelectAssetAction: (() -> Void)
    
    public init(
        onSelectAssetAction: @escaping () -> Void
    ) {
        self.onSelectAssetAction = onSelectAssetAction
    }
    
    public var body: some View {
        Button(role: .none) {
            onSelectAssetAction()
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
