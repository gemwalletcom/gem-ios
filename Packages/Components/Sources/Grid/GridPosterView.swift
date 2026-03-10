// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct GridPosterView: View {

    private let assetImage: AssetImage
    private let title: String?
    private let count: Int?
    private let isVerified: Bool

    public init(
        assetImage: AssetImage,
        title: String?,
        count: Int? = nil,
        isVerified: Bool = false
    ) {
        self.assetImage = assetImage
        self.title = title
        self.count = count
        self.isVerified = isVerified
    }

    public var body: some View {
        VStack(alignment: .leading) {
            NftImageView(assetImage: assetImage)
                .clipShape(RoundedRectangle(cornerRadius: .medium))
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .topTrailing) {
                    if let count {
                        countBadge(count)
                    }
                }

            if let title {
                HStack(spacing: Spacing.tiny) {
                    Text(title)
                        .font(.body)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)

                    if isVerified {
                        Images.System.checkmarkSealFill
                            .font(.callout)
                            .foregroundStyle(Colors.blue)
                    }
                }
            }
            Spacer()
        }
    }

    private func countBadge(_ count: Int) -> some View {
        Text(String(count))
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Colors.whiteSolid)
            .padding(.horizontal, .space6)
            .frame(minWidth: .space24, minHeight: .space24)
            .background(Colors.Empty.image)
            .clipShape(RoundedRectangle(cornerRadius: .small))
            .padding(.space8)
    }
}

#Preview {
    GridPosterView(
        assetImage: AssetImage(
            imageURL: URL(string: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png"),
            placeholder: nil,
            chainPlaceholder: nil
        ),
        title: "gemcoder.eth"
    )
    .frame(width: 300, height: 300)
}
