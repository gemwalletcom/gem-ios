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
    
    private var swapProvider: String? {
        guard case let .swap(metadata) = transactionViewModel.transaction.transaction.metadata else {
            return nil
        }
        return metadata.provider
    }
    
    private var transactionLink: BlockExplorerLink {
        explorerService.transactionUrl(
            chain: transactionViewModel.transaction.transaction.assetId.chain,
            hash: transactionViewModel.transaction.transaction.hash,
            swapProvider: swapProvider
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
