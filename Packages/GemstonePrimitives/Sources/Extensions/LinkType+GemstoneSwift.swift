// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

extension LinkType {
    public var order: Int {
        linkTypeOrder(linkType: self.rawValue).asInt
    }
}
