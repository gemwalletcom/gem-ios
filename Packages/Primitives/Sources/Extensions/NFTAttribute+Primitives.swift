// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension NFTAttribute: Identifiable {
    public var id: String {
        name + value 
    }
}
