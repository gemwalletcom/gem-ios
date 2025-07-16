// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import func Gemstone.linkTypeOrder

extension LinkType {
    public var order: Int {
        linkTypeOrder(linkType: self.rawValue).asInt
    }
}
