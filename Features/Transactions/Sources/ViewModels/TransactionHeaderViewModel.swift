// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import SwiftUI
import Localization

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

    public var swapAgainText: String { Localized.Transaction.swapAgain }

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
    
    public var showSwapAgain: Bool {
        switch headerType {
        case .amount, .nft: false
        case .swap: true
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

    public var itemModel: TransactionHeaderItemModel {
        TransactionHeaderItemModel(
            headerType: headerType,
            showClearHeader: showClearHeader
        )
    }
}
