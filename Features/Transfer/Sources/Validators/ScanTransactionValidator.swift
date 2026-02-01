// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives

struct ScanTransactionValidator {
    static func validate(
        transaction: ScanTransaction,
        asset: Asset,
        memo: String?
    ) throws {
        if transaction.isMalicious {
            throw ScanTransactionError.malicious
        }

        if transaction.isMemoRequired, memo?.isEmpty ?? true {
            throw ScanTransactionError.memoRequired(symbol: asset.symbol)
        }
    }
}
