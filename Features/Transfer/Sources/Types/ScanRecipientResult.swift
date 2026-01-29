// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct PaymentScanResult {
    let address: String
    let amount: String?
    let memo: String?
    
    init(address: String, amount: String?, memo: String?) {
        self.address = address
        self.amount = amount
        self.memo = memo
    }
}
