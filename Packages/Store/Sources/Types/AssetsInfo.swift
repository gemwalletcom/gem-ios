// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AssetsInfo: Sendable {
    public let hidden: Int
    
    public init(hidden: Int) {
        self.hidden = hidden
    }
}
