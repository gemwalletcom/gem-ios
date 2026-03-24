// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct NftImagePlaceholderView: View {

    private let name: String?

    public init(name: String? = nil) {
        self.name = name
    }

    public var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let showName = size > 250
            let circleSize = size * (showName ? 0.3 : 0.35)
            let iconSize = circleSize * 0.45
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
