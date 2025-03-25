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
        CachedAsyncImage(url: assetImage.imageURL, scale: UIScreen.main.scale) {
            $0.resizable()
                .animation(.default)
        } placeholder: {
            if let image = assetImage.placeholder {
                image.resizable()
                    .cornerRadius(cornerRadius)
            } else if let type = assetImage.type {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundStyle(.tertiary)
                    Text(type)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .padding(4)
                }
            }
        }
        .cornerRadius(cornerRadius)
        .overlay(
            assetImage.chainPlaceholder?
                .resizable()
                .cornerRadius(overlayImageCornerRadiusInside)
                .aspectRatio(contentMode: .fit)
                .frame(width: overlayImageSize, height: overlayImageSize)
                .padding(overlayImagePadding)
                .background(Colors.grayBackground)
                .cornerRadius(overlayImageCornerRadiusOutside)
                .offset(x: overlayImageOffsetXY, y: overlayImageOffsetXY)
        )
        .frame(width: imageSize, height: imageSize)
    }
}

#Preview {
    Group {
        // Light mode preview
        AssetImageView(
            assetImage: AssetImage(
                type: "SPL",
                imageURL: URL(string: "https://example.com/token.png"),
                placeholder: Image(systemName: "bitcoinsign.circle"),
                chainPlaceholder: Image(systemName: "bolt.circle.fill")
            ),
            size: 50,
            overlayImageSize: 20
        )

        // Dark mode preview
        AssetImageView(
            assetImage: AssetImage(
                type: "SPL", imageURL: nil,
                placeholder: nil,
                chainPlaceholder: Image(systemName: "bolt.circle.fill")
            ),
            size: 50,
            overlayImageSize: 20
        )
    }
}

