// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension FiatTransaction {
    public static func mock(
        id: String = "mock_id",
        assetId: AssetId = .mock(),
        transactionType: FiatQuoteType = .buy,
        provider: FiatProviderName = .moonPay,
        status: FiatTransactionStatus = .complete,
        fiatAmount: Double = 100.0,
        fiatCurrency: String = "USD",
        value: String = "0",
        createdAt: Date = .now
    ) -> FiatTransaction {
        FiatTransaction(
            id: id,
            assetId: assetId,
            transactionType: transactionType,
            provider: provider,
            status: status,
            fiatAmount: fiatAmount,
            fiatCurrency: fiatCurrency,
            value: value,
            createdAt: createdAt
        )
    }
}

extension FiatTransactionInfo {
    public static func mock(
        transaction: FiatTransaction = .mock(),
        asset: Asset = .mock(),
        detailsUrl: String? = nil
    ) -> FiatTransactionInfo {
        FiatTransactionInfo(
            transaction: transaction,
            asset: asset,
            detailsUrl: detailsUrl
        )
    }
}
