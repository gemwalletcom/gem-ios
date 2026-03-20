// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Style

public struct FiatAmountDisplay: @unchecked Sendable, AmountDisplayable {
    public let amount: TextValue
    public let fiat: TextValue? = nil
    public let assetImage: AssetImage?

    public init(amount: TextValue, assetImage: AssetImage?) {
        self.amount = amount
        self.assetImage = assetImage
    }
}
