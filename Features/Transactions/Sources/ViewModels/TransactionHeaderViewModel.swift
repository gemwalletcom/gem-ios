// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import SwiftUI
import Localization
import Components

public struct TransactionHeaderViewModel: Sendable {
    private let transaction: TransactionExtended
    private let infoModel: TransactionInfoViewModel
    
    public init(
        transaction: TransactionExtended,
        infoModel: TransactionInfoViewModel
    ) {
        self.transaction = transaction
        self.infoModel = infoModel
    }

    public var headerType: TransactionHeaderType {
        let metadata: TransactionExtendedMetadata? = {
            guard let metadata = transaction.transaction.metadata else {
                return nil
            }
            return TransactionExtendedMetadata(
                assets: transaction.assets,
                assetPrices: transaction.prices,
                transactionMetadata: metadata
            )
        }()
        
        return TransactionHeaderTypeBuilder.build(
            infoModel: infoModel,
            transaction: transaction.transaction,
            metadata: metadata
        )
    }
    
    public var showClearHeader: Bool {
        switch headerType {
        case .amount, .nft: true
        case .swap: false
        }
    }

    public var headerLink: URL? {
        switch transaction.transaction.metadata {
        case .null, .nft, .none, .perpetual: 
            nil
        case let .swap(metadata): 
            DeepLink.swap(metadata.fromAsset, metadata.toAsset).localUrl
        }
    }
}

// MARK: - ItemModelProvidable

extension TransactionHeaderViewModel: ItemModelProvidable {
    public var itemModel: TransactionItemModel {
        .header(
            TransactionHeaderItemModel(
                headerType: headerType,
                showClearHeader: showClearHeader
            )
        )
    }
}
