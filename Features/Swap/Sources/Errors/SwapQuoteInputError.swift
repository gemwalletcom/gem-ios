// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum SwapQuoteInputError: Error {
    case invalidAmount
    case formatingError
    case missingFromAsset
    case missingToAsset
}
