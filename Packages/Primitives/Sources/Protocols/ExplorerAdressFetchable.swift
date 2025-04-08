// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol ExplorerLinkFetchable: Sendable {
    func addressUrl(chain: Chain, address: String) -> BlockExplorerLink
    func transactionUrl(chain: Chain, hash: String, swapProvider: String?) -> BlockExplorerLink
}
