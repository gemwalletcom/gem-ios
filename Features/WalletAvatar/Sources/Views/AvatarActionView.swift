// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Primitives

public struct AvatarActionView: View {
    let walletId: String
    let imageSize: CGFloat
    let overlayImageSize: CGFloat
    let action: VoidAction
    
    public init(
        walletId: String,
        imageSize: CGFloat,
        overlayImageSize: CGFloat,
        action: VoidAction
    ) {
        self.walletId = walletId
        self.imageSize = imageSize
        self.overlayImageSize = overlayImageSize
        self.action = action
    }
    
    public static let defaultImageSize: CGFloat = 40
    
    private var overlayImageOffset: CGFloat {
        imageSize/2-overlayImageSize/2
    }
    private var overlayImageCornerRadiusInside: CGFloat {
        overlayImageSize / 2
    }
    private var overlayImagePadding: CGFloat {
        (imageSize / Self.defaultImageSize).rounded(.up)
    }
    private var overlayImageCornerRadiusOutside: CGFloat {
        overlayImageSize / 2 + overlayImagePadding
    }
    private var overlayImageOffsetXY: CGFloat {
        overlayImageOffset + (imageSize / overlayImageSize)
    }
    
    public var body: some View {
        AvatarView(
            walletId: walletId,
            imageSize: imageSize,
            overlayImageSize: overlayImageSize
        )
        .overlay(content: {
            Image(systemName: SystemImage.pencil)
                .resizable()
                .padding(Spacing.small)
                .background(Colors.gray)
                .foregroundStyle(Colors.whiteSolid)
                .cornerRadius(overlayImageCornerRadiusInside)
                .aspectRatio(contentMode: .fit)
                .frame(width: overlayImageSize, height: overlayImageSize)
                .padding(overlayImagePadding)
                .background(Colors.white)
                .cornerRadius(overlayImageCornerRadiusOutside)
                .offset(x: overlayImageOffsetXY, y: overlayImageOffsetXY)
        })
        .onTapGesture {
            action?()
        }
        .frame(width: imageSize, height: imageSize)
    }
}
