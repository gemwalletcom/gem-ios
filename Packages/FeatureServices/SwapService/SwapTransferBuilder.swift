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
        let recipient = Recipient(
            name: .none,
            address: try wallet.account(for: toAsset.chain).address,
            memo: .none
        )
        let result = SwapData(
            quote: quote.map(),
            data: quoteData.map(quote: quote.map())
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
