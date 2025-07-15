// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.PaymentWrapper
import func Gemstone.paymentDecodeUrl

public struct PaymentURLDecoder {
    public static func decode(_ string: String) throws -> PaymentWrapper {
        return try paymentDecodeUrl(string: string)
    }
}
