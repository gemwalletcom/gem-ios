// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension AssetLink {
    public var linkType: LinkType? {
        LinkType(rawValue: name)
    }
}

extension AssetLink: @retroactive Comparable {
    // Conforming to Comparable for sorting
    public static func < (lhs: AssetLink, rhs: AssetLink) -> Bool {
        if let lhsLink = lhs.linkType, let rhsLink = rhs.linkType  {
            return lhsLink.order > rhsLink.order
        }
        return false
    }
}
