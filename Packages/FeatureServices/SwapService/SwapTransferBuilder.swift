// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import struct Gemstone.GemSwapQuoteData
import struct Gemstone.SwapperQuote
import Primitives

public struct SwapTransferDataFactory: Sendable {
    public static func swap(
        wallet: Wallet,
        fromAsset: Asset,
        toAsset: Asset,
        quote: Gemstone.SwapperQuote,
        quoteData: Gemstone.GemSwapQuoteData
    ) throws -> TransferData {
        let recipient = try Recipient(
            name: .none,
            address: wallet.account(for: toAsset.chain).address,
            memo: .none
        )
        let result = try SwapData(
            quote: quote.map(),
            data: quoteData.map()
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
