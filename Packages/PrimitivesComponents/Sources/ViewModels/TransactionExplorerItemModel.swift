// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components
import Style

public struct TransactionExplorerItemModel {
    private let explorerUrl: URL
    private let explorerName: String
    
    public init(transaction: TransactionExtended, explorerService: any ExplorerLinkFetchable) {
        let chain = transaction.transaction.assetId.chain
        let swapProvider: String? = {
            guard case let .swap(metadata) = transaction.transaction.metadata else { return nil }
            return metadata.provider
        }()
        let transactionLink = explorerService.transactionUrl(
            chain: chain,
            hash: transaction.transaction.hash,
            swapProvider: swapProvider
        )
        self.explorerUrl = transactionLink.url
        self.explorerName = transactionLink.name
    }
    
    public var url: URL {
        explorerUrl
    }
    
    public var text: String {
        Localized.Transaction.viewOn(explorerName)
    }
}
