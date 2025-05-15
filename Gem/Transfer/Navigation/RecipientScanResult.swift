// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum RecipientScanResult {
    case recipient(address: String, memo: String?, amount: String?)
    case transferData(TransferData)
}
