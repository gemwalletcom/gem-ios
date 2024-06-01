// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum ScanRecipientResult {
    case address(address: String, memo: String?)
    case transfer(TransferData)
}
