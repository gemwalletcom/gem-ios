// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Primitives
import PrimitivesComponents
import Components
import GRDBQuery
import Store

public struct AvatarView: View {
    @Query<WalletRequest>
    private var wallet: Wallet?
    
    private let imageSize: CGFloat
    private var overlayImageSize: CGFloat { imageSize / (2 * sqrt(2)) }

    public init(
        walletId: String,
        size: CGFloat
    ) {
        self.imageSize = size
        _wallet = Query(WalletRequest(walletId: walletId))
    }
    
    public var body: some View {
        if let wallet {
            AssetImageView(
                assetImage: WalletViewModel(wallet: wallet).avatarImage,
                size: imageSize,
                overlayImageSize: overlayImageSize
            )
            .frame(width: imageSize, height: imageSize)
            .transition(.opacity)
        }
    }
}
