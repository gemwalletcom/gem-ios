// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

public struct NftPreviewView: View {
    private let assetImage: AssetImage
    private let name: String?
    private let size: CGFloat

    public init(assetImage: AssetImage, name: String?, size: CGFloat) {
        self.assetImage = assetImage
        self.name = name
        self.size = size
    }

    public var body: some View {
        VStack(spacing: .medium) {
            NftImageView(assetImage: assetImage)
                .frame(width: size, height: size)
                .cornerRadius(size / 4)
            if let name {
                Text(name)
                    .textStyle(.headline)
                    .lineLimit(1)
            }
        }
    }
}
