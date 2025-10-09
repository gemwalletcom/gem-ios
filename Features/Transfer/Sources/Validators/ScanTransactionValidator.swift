// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives

public struct ScanTransactionValidator {
    public static func validate(
        transaction: ScanTransaction,
        with payload: ScanTransactionPayload
    ) throws {
        if transaction.isMalicious {
            throw ScanTransactionError.malicious
        }

        if payload.type == .transfer, transaction.isMemoRequired {
            throw ScanTransactionError.memoRequired(symbol: payload.target.chain.asset.symbol)
        }
    }
}
