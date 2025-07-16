// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import func Gemstone.paymentDecodeUrl
import struct Gemstone.PaymentWrapper

public struct PaymentURLDecoder {
    public static func decode(_ string: String) throws -> PaymentWrapper {
        return try paymentDecodeUrl(string: string)
    }
}
