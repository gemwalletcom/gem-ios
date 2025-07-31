// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ChainService

public extension ChainServiceFactory {
    static func mock(
        nodeProvider: any NodeURLFetchable = NodeURLFetchableMock(url: URL(string: "https://gemwallet.com/")!)
    ) -> ChainServiceFactory {
        ChainServiceFactory(nodeProvider: nodeProvider)
    }
}
