// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import struct Gemstone.SwapperQuote
import struct Gemstone.SwapperQuoteData

public struct SwapTransferDataFactory: Sendable {
    public static func swap(
        fromAsset: Asset,
        toAsset: Asset,
        quote: Gemstone.SwapperQuote,
        quoteData: Gemstone.SwapperQuoteData
    ) -> TransferData {
        let recipient = Recipient(
            name: quote.data.provider.name,
            address: quoteData.to,
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
            value: BigInt(stringLiteral: quote.request.value)
        )
    }
}
