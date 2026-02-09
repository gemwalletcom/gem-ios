// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension SwapQuoteData {
    static func mock(
        data: String = ""
    ) -> SwapQuoteData {
        SwapQuoteData(
            to: "",
            dataType: .contract,
            value: "",
            data: data,
            memo: nil,
            approval: nil,
            gasLimit: nil
        )
    }
}
