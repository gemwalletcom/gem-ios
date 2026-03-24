// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct NftImagePlaceholderView: View {

    private let name: String?

    public init(name: String? = nil) {
        self.name = name
    }

    private struct Layout {
        static let nameVisibilityThreshold: CGFloat = 250
        static let circleSizeRatioWithText: CGFloat = 0.3
        static let circleSizeRatioDefault: CGFloat = 0.35
        static let iconSizeRatio: CGFloat = 0.45
    }

    public var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let showName = size > Layout.nameVisibilityThreshold
            let circleSize = size * (showName ? Layout.circleSizeRatioWithText : Layout.circleSizeRatioDefault)
            let iconSize = circleSize * Layout.iconSizeRatio
            ZStack {
                Color(.systemGray5)
                VStack(spacing: Spacing.medium) {
                    ZStack {
                        Circle()
                            .foregroundStyle(Color(.systemGray4))
                        Images.System.photo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: iconSize, height: iconSize)
                            .foregroundStyle(Colors.Empty.image)
                    }
                    .frame(size: circleSize)

                    if showName, let name, !name.isEmpty {
                        Text(name)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(Color(.secondaryLabel))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.extraLarge)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
