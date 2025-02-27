// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import PrimitivesComponents

public struct AvatarView: View {
    
    let model: WalletViewModel
    let size: CGFloat
    
    public var body: some View {
        AssetImageView(
            assetImage: model.avatarImage,
            size: size,
            overlayImageSize: .image.medium
        )
    }
}
