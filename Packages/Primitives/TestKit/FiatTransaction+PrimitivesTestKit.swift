// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension FiatTransaction {
    public static func mock(
        id: String = "mock_id",
        assetId: AssetId = .mock(),
        transactionType: FiatQuoteType = .buy,
        providerId: FiatProviderName = .moonPay,
        providerTransactionId: String? = "mock_tx_123",
        status: FiatTransactionStatus = .complete,
        fiatAmount: Double = 100.0,
        fiatCurrency: String = "USD",
        value: String = "0",
        transactionHash: String? = nil,
        address: String? = "0x1234567890abcdef",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) -> FiatTransaction {
        FiatTransaction(
            id: id,
            assetId: assetId,
            transactionType: transactionType,
            providerId: providerId,
            providerTransactionId: providerTransactionId,
            status: status,
            fiatAmount: fiatAmount,
            fiatCurrency: fiatCurrency,
            value: value,
            transactionHash: transactionHash,
            address: address,
            createdAt: createdAt,
            updatedAt: updatedAt
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
