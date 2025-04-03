// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct AssetImageView: View {
    @Environment(\.displayScale) private var scale

    private let size: CGFloat
    private let overlaySize: CGFloat
    private let assetImage: AssetImage
    private let overlayPadding: CGFloat = 2
    private let cornerRadius: CGFloat

    public init(
        assetImage: AssetImage,
        size: CGFloat = .image.asset,
        overlayImageSize: CGFloat = 16,
        cornerRadius: CGFloat? = nil
    ) {
        self.assetImage = assetImage
        self.size = max(1, size)
        self.overlaySize = max(1, overlayImageSize)
        self.cornerRadius = cornerRadius ?? size / 2
    }

    private var overlayOffset: CGFloat { (size / 2) - (overlaySize / 2) }

    public var body: some View {
        CachedAsyncImage(
            url: assetImage.imageURL,
            scale: scale,
            content: {
                $0.resizable().animation(.default)
            },
            placeholder: {
                placeholderView
            }
        )
        .frame(width: size, height: size)
        .cornerRadius(cornerRadius)
        .overlay(overlayBadge)
    }

    @ViewBuilder
    private var placeholderView: some View {
        if let placeholderImage = assetImage.placeholder {
            placeholderImage
                .resizable()
                .scaledToFill()
                .cornerRadius(cornerRadius)
        } else if let tokenType = assetImage.type {
            GeometryReader { geo in
                let diameter = min(geo.size.width, geo.size.height)
                ZStack {
                    Circle().foregroundStyle(.tertiary)
                    Text(tokenType.uppercased())
                        .font(.system(size: diameter * 0.3, weight: .semibold))
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .tiny + .extraSmall)
                        .foregroundColor(.primary)
                }
            }
        } else {
            Rectangle()
                .foregroundStyle(.tertiary)
                .cornerRadius(cornerRadius)
        }
    }

    @ViewBuilder
    private var overlayBadge: some View {
        if let badgeImage = assetImage.chainPlaceholder {
            badgeImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: overlaySize, height: overlaySize)
                .padding(overlayPadding)
                .background(Colors.grayBackground)
                .clipShape(Circle())
                .offset(x: overlayOffset + (size / overlaySize), y: overlayOffset + (size / overlaySize))
        }
    }
}

#Preview {
    Group {
        AssetImageView(
            assetImage: AssetImage(
                type: "SPL",
                imageURL: URL(string: "https://example.com/token.png"),
                placeholder: Image(systemName: "bitcoinsign.circle"),
                chainPlaceholder: Image(systemName: "bolt.circle.fill")
            ),
            size: .image.medium,
            overlayImageSize: 20
        )

        AssetImageView(
            assetImage: AssetImage(
                type: "MIGRAINE",
                imageURL: nil,
                placeholder: nil,
                chainPlaceholder: Image(systemName: "bolt.circle.fill")
            ),
            size: .image.medium,
            overlayImageSize: 20
        )
        .preferredColorScheme(.dark)
    }
}
