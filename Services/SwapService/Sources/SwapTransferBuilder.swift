// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import struct Gemstone.SwapQuote
import struct Gemstone.SwapQuoteData

public struct SwapTransferDataFactory: Sendable {
    public static func swap(
        fromAsset: Asset,
        toAsset: Asset,
        quote: Gemstone.SwapQuote,
        quoteData: Gemstone.SwapQuoteData
    ) -> TransferData {
        let recipient = Recipient(
            name: quote.data.provider.name,
            address: quoteData.to,
            memo: .none
        )

        return TransferData(
            type: .swap(
                fromAsset,
                toAsset,
                quoteData.asPrimitive(quote: quote.asPrimitive)
            ),
            recipientData: RecipientData(recipient: recipient, amount: .none),
            value: BigInt(stringLiteral: quote.request.value),
            canChangeValue: true
        )
    }
}
