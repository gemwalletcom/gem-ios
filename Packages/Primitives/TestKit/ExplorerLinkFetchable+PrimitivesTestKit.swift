// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct MockExplorerLink: ExplorerLinkFetchable {
    public init() {}

    public func addressUrl(chain: Chain, address: String) -> BlockExplorerLink {
        BlockExplorerLink(
            name: "MockExplorer",
            link: "https://mock.explorer/\(chain.rawValue)/address/\(address)"
        )
    }

    public func transactionUrl(chain: Chain, hash: String) -> BlockExplorerLink {
        BlockExplorerLink(
            name: "MockExplorer",
            link: "https://mock.explorer/\(chain.rawValue)/tx/\(hash)"
        )
    }
}
