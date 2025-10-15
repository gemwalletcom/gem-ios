// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol ExplorerLinkFetchable: Sendable {
    func addressUrl(chain: Chain, address: String) -> BlockExplorerLink
    func transactionUrl(chain: Chain, hash: String) -> BlockExplorerLink
    func swapTransactionUrl(chain: Chain, provider: String, identifier: String) -> BlockExplorerLink?
    func swapIdentifier(chain: Chain, provider: String, hash: String, recipient: String?) -> String
}

public extension ExplorerLinkFetchable {
    func swapIdentifier(
        chain: Chain,
        provider: String,
        hash: String,
        recipient: String?
    ) -> String {
        hash
    }

    func transactionLink(
        chain: Chain,
        provider: String?,
        hash: String,
        recipient: String?
    ) -> BlockExplorerLink {
        guard
            let provider,
            !provider.isEmpty
        else {
            return transactionUrl(chain: chain, hash: hash)
        }

        let identifier = swapIdentifier(
            chain: chain,
            provider: provider,
            hash: hash,
            recipient: recipient
        )

        if let link = swapTransactionUrl(chain: chain, provider: provider, identifier: identifier) {
            return link
        }

        return transactionUrl(chain: chain, hash: hash)
    }
}
