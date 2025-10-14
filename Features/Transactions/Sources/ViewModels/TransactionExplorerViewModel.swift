// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization
import Components

public struct TransactionExplorerViewModel: Sendable {
    private let transactionViewModel: TransactionViewModel
    private let explorerService: any ExplorerLinkFetchable
    
    public init(
        transactionViewModel: TransactionViewModel,
        explorerService: any ExplorerLinkFetchable
    ) {
        self.transactionViewModel = transactionViewModel
        self.explorerService = explorerService
    }
    
    private var transactionLink: BlockExplorerLink {
        let chain = transactionViewModel.transaction.transaction.assetId.chain
        let hash = transactionViewModel.transaction.transaction.hash
        return explorerService.transactionLink(
            chain: chain,
            provider: transactionViewModel.transaction.transaction.swapProvider,
            hash: hash,
            recipient: transactionViewModel.transaction.transaction.to
        )
    }
    
    public var url: URL {
        transactionLink.url
    }
}

// MARK: - ItemModelProvidable

extension TransactionExplorerViewModel: ItemModelProvidable {
    public var itemModel: TransactionItemModel {
        .explorer(
            url: transactionLink.url,
            text: Localized.Transaction.viewOn(transactionLink.name)
        )
    }
}
