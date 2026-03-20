// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension FiatTransaction {
    public static func mock(
        assetId: AssetId? = .mock(),
        transactionType: FiatQuoteType = .buy,
        providerId: FiatProviderName = .moonPay,
        providerTransactionId: String = "mock_tx_123",
        status: FiatTransactionStatus = .complete,
        fiatAmount: Double = 100.0,
        fiatCurrency: String = "USD",
        transactionHash: String? = nil,
        address: String? = "0x1234567890abcdef"
    ) -> FiatTransaction {
        FiatTransaction(
            assetId: assetId,
            transactionType: transactionType,
            providerId: providerId,
            providerTransactionId: providerTransactionId,
            status: status,
            fiatAmount: fiatAmount,
            fiatCurrency: fiatCurrency,
            transactionHash: transactionHash,
            address: address
        )
    }
}