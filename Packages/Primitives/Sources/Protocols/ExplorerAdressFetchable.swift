// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol ExplorerLinkFetchable: Sendable {
    func addressUrl(chain: Chain, address: String) -> BlockExplorerLink
    func transactionUrl(chain: Chain, hash: String) -> BlockExplorerLink
    func swapTransactionUrl(chain: Chain, provider: String, identifier: String) -> BlockExplorerLink?
}

public extension ExplorerLinkFetchable {
    func transactionLink(
        chain: Chain,
        provider: String?,
        hash: String,
        recipient: String
    ) -> BlockExplorerLink {
        guard
            let provider,
            let swapProvider = SwapProvider(rawValue: provider)
        else {
            return transactionUrl(chain: chain, hash: hash)
        }

        let identifier = if swapProvider == .nearIntents {
            recipient
        } else {
            hash
        }

        if let link = swapTransactionUrl(chain: chain, provider: provider, identifier: identifier) {
            return link
        }

        return transactionUrl(chain: chain, hash: hash)
    }
}
