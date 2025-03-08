// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension AssetLink {
    static func mock(
        type: LinkType = .website,
        url: String = "https://example.com"
    ) -> AssetLink {
        AssetLink(
            name: type.rawValue,
            url: url
        )
    }
}
