// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone

public struct PaymentURLDecoder {
    public static func decode(_ string: String) throws -> PaymentWrapper {
        return try Gemstone.paymentDecodeUrl(string: string)
    }
}
