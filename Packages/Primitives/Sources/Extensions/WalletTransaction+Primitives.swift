// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension TransactionWallet {
    var assetIdentifiers: [AssetId] {
        (transaction.assetIds + [transaction.feeAssetId]).unique()
    }

    var assetId: AssetId {
        transaction.assetId
    }

    var type: TransactionType {
        transaction.type
    }
}
