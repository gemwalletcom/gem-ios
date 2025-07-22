// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import struct Gemstone.SwapperQuote
import struct Gemstone.SwapperQuoteData

public struct SwapTransferDataFactory: Sendable {
    public static func swap(
        wallet: Wallet,
        fromAsset: Asset,
        toAsset: Asset,
        quote: Gemstone.SwapperQuote,
        quoteData: Gemstone.SwapperQuoteData
    ) throws -> TransferData {

        let address: String = try {
            if quoteData.to.isEmpty {
                return try wallet.account(for: toAsset.chain).address
            }
            return quoteData.to
        }()

        let recipient = Recipient(
            name: quote.data.provider.name,
            address: address,
            memo: .none
        )
        
        let result = SwapData(
            quote: quote.asPrimitive,
            data: quoteData.asPrimitive(quote: quote.asPrimitive)
        )

        return TransferData(
            type: .swap(
                fromAsset,
                toAsset,
                result
            ),
            recipientData: RecipientData(recipient: recipient, amount: .none),
            value: BigInt(stringLiteral: quote.request.value),
            canChangeValue: true
        )
    }
}
