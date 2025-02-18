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
    private let overlayImageSize: CGFloat

    public init(
        walletId: String,
        imageSize: CGFloat,
        overlayImageSize: CGFloat
    ) {
        self.imageSize = imageSize
        self.overlayImageSize = overlayImageSize
        _wallet = Query(WalletRequest(walletId: walletId))
    }
    
    public var body: some View {
        VStack {
            if let wallet {
                AssetImageView(
                    assetImage: WalletViewModel(wallet: wallet).avatarImage,
                    size: imageSize,
                    overlayImageSize: overlayImageSize
                )
                .id(wallet.imageUrl)
            }
        }
        .frame(width: imageSize, height: imageSize)
        .animation(.default, value: wallet?.imageUrl)
    }
}
