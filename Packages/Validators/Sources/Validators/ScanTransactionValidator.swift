// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct ScanTransactionValidator {
    public static func validate(
        transaction: ScanTransaction,
        with payload: ScanTransactionPayload
    ) throws {
        if transaction.isMalicious {
            throw ScanTransactionError.malicious
        }

        if payload.type == .transfer, transaction.isMemoRequired {
            throw ScanTransactionError.memoRequired(chain: payload.target.chain)
        }
    }
}
