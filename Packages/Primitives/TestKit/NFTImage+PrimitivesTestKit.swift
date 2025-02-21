// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension NFTImage {
    static func mock(
        imageURL: String = "https://example.com",
        previewImageUrl: String = "https://preview.example.com",
        originalSourceUrl: String = "https://original.source.example.com"
    )-> NFTImage {
        NFTImage(
            imageUrl: imageURL,
            previewImageUrl: previewImageUrl,
            originalSourceUrl: originalSourceUrl
        )
    }
}
