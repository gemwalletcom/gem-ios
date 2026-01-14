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
        TransactionHeaderTypeBuilder.build(
            infoModel: infoModel,
            transaction: transaction.transaction,
            metadata: TransactionExtendedMetadata(
                assets: transaction.assets,
                assetPrices: transaction.prices,
                metadata: transaction.transaction.metadata
            )
        )
    }

    public var showClearHeader: Bool {
        switch headerType {
        case .amount, .nft: true
        case .swap: false
        }
    }

    public var headerLink: URL? {
        guard let swapMetadata = transaction.transaction.metadata?.decode(TransactionSwapMetadata.self) else {
            return nil
        }
        return DeepLink.swap(swapMetadata.fromAsset, swapMetadata.toAsset).localUrl
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
