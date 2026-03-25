// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct NftImageView: View {

    private let assetImage: AssetImage
    @Binding private var isImageLoaded: Bool

    public init(
        assetImage: AssetImage,
        isImageLoaded: Binding<Bool> = .constant(false)
    ) {
        self.assetImage = assetImage
        _isImageLoaded = isImageLoaded
    }

    public var body: some View {
        CachedAsyncImage(url: assetImage.imageURL) { phase in
            switch phase {
            case .empty:
                if assetImage.imageURL != nil {
                    ZStack {
                        Color(.systemGray5)
                        if assetImage.placeholder != nil {
                            AssetImageView(
                                assetImage: assetImage,
                                size: .image.large
                            )
                        } else {
                            LoadingView()
                        }
                    }
                } else {
                    NftImagePlaceholderView(name: assetImage.type)
                }
            case .success(let image):
                image.resizable()
                    .onAppear { isImageLoaded = true }
            case .failure:
                NftImagePlaceholderView(name: assetImage.type)
            @unknown default:
                NftImagePlaceholderView(name: assetImage.type)
            }
        }
    }
}
