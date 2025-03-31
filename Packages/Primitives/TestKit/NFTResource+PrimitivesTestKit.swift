// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension NFTResource {
    static func mock(
        url: String = "https://example.com",
        mimeType: String = "image/png"
    )-> NFTResource {
        NFTResource(
            url: url,
            mimeType: mimeType
        )
    }
}
