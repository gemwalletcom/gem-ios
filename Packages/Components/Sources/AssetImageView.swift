// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct AssetImageView: View {
    
    let assetImage: AssetImage
    let cornerRadius: CGFloat
    let size: CGFloat
    
    let overlayImageSize: CGFloat
    let overlayImageSizePadding: CGFloat = 2
    var overlayImageOffset: CGFloat {
        size/2-overlayImageSize/2
    }
    
    public init(
        assetImage: AssetImage,
        size: CGFloat = 40,
        overlayImageSize: CGFloat = 16
    ) {
        self.assetImage = assetImage
        self.size = size
        self.cornerRadius = size / 2
        self.overlayImageSize = overlayImageSize
    }

    public var body: some View {
        ZStack {
            if let image = assetImage.placeholder {
                image.resizable()
                .cornerRadius(cornerRadius)
            } else {
                CachedAsyncImage(url: assetImage.imageURL, scale: 1) {
                    $0.resizable()
                } placeholder: {
                    ZStack {
                        Text(assetImage.type)
                            .lineLimit(1)
                            .minimumScaleFactor(0.3)
                            .padding(4)
                    }
                    .frame(width: size, height: size)
                    .cornerRadius(cornerRadius)
                    .background(Colors.grayBackground)
                }
                .cornerRadius(cornerRadius)
            }
        }
        .overlay(
            assetImage.chainPlaceholder?
                .resizable()
                .cornerRadius(overlayImageSize/2)
                .aspectRatio(contentMode: .fit)
                .frame(width: overlayImageSize, height: overlayImageSize)
                .padding(1)
                .background(Colors.white)
                .cornerRadius(overlayImageSize+overlayImageSizePadding*2/2)
                .offset(x: overlayImageOffset + 2, y: overlayImageOffset + 2)
        )
        .frame(width: size, height: size)
    }
}
