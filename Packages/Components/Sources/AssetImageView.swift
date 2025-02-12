// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct AssetImageView: View {
    
    let assetImage: AssetImage
    let cornerRadius: CGFloat
    let imageSize: CGFloat
    
    let overlayImageSize: CGFloat
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
    
    public init(
        assetImage: AssetImage,
        size: CGFloat = Self.defaultImageSize,
        overlayImageSize: CGFloat = 16
    ) {
        self.assetImage = assetImage
        self.imageSize = size
        self.cornerRadius = size / 2
        self.overlayImageSize = overlayImageSize
    }

    public var body: some View {
        ZStack {
            if let image = assetImage.placeholder {
                image.resizable()
                .cornerRadius(cornerRadius)
            } else {
                CachedAsyncImage(url: assetImage.imageURL, scale: UIScreen.main.scale) {
                    $0.resizable()
                } placeholder: {
                    if let type = assetImage.type {
                        ZStack {
                            Text(type)
                                .lineLimit(1)
                                .minimumScaleFactor(0.3)
                                .padding(4)
                        }
                        .frame(width: imageSize, height: imageSize)
                        .cornerRadius(cornerRadius)
                        .background(Colors.grayBackground)
                    }
                }
                .cornerRadius(cornerRadius)
            }
        }
        .overlay(
            assetImage.chainPlaceholder?
                .resizable()
                .cornerRadius(overlayImageCornerRadiusInside)
                .aspectRatio(contentMode: .fit)
                .frame(width: overlayImageSize, height: overlayImageSize)
                .padding(overlayImagePadding)
                .background(Colors.white)
                .cornerRadius(overlayImageCornerRadiusOutside)
                .offset(x: overlayImageOffsetXY, y: overlayImageOffsetXY)
        )
        .frame(width: imageSize, height: imageSize)
    }
}
