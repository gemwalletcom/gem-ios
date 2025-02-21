// Copyright (c). Gem Wallet. All rights reserved.


import Foundation
import Gemstone
import Primitives

extension AssetLink {
    public var linkType: LinkType? {
        LinkType(rawValue: name)
    }
}
