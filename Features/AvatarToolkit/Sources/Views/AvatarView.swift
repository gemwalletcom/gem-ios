// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Primitives
import PrimitivesComponents
import Components
import GRDBQuery
import Store
import Keystore

public struct AvatarView: View {
    @State private var model: AvatarViewModel
    
    @Query<AvatarRequest>
    private var avatar: AvatarValue?
    
    public init(
        model: AvatarViewModel,
        size: CGFloat
    ) {
        self.imageSize = size
        _model = State(wrappedValue: model)
        _avatar = Query(constant: model.avatarRequest)
    }
    
    private let imageSize: CGFloat
    private var radius: CGFloat { imageSize / 2 }
    private var offset: CGFloat { sqrt(radius * radius / 2) }
    
    public var body: some View {
        ZStack() {
            AssetImageView(
                assetImage: model.avatarAssetImage ?? model.defaultAvatar,
                size: imageSize,
                overlayImageSize: offset
            )
            .frame(width: imageSize, height: imageSize)
            .transition(.opacity)
            .id(model.wallet.id)
            
            if model.allowEditing, model.clearButtonIsVisible {
                Button(action: {
                    withAnimation {
                        model.setAvatar(nil)
                    }
                }) {
                    Image(systemName: SystemImage.xmark)
                        .foregroundColor(Colors.black)
                        .padding(Spacing.small)
                        .background(Colors.grayVeryLight)
                        .clipShape(Circle())
                        .background(
                            Circle().stroke(Colors.white, lineWidth: Spacing.extraSmall)
                        )
                }
                .offset(x: offset, y: -offset)
                .transition(.opacity)
            }
        }
        .onChange(of: avatar, initial: true, model.onChangeAvatar)
    }
}

#Preview {
    AvatarView(
        model: AvatarViewModel(
            wallet: .makeView(
                name: .empty,
                chain: .ethereum,
                address: .empty
            ),
            allowEditing: true
        ),
        size: Sizing.image.extraLarge
    )
}
