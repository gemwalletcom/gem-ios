// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@testable import Primitives

public extension BlockExplorerLink {
    static func mock() -> BlockExplorerLink {
        BlockExplorerLink(name: "Mock", link: "https://mock.com")
    }
}