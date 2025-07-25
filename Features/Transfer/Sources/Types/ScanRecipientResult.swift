// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct PaymentScanResult {
    public let address: String
    public let amount: String?
    public let memo: String?
    
    public init(address: String, amount: String?, memo: String?) {
        self.address = address
        self.amount = amount
        self.memo = memo
    }
}
