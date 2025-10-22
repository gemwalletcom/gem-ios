// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum TransferState: Sendable, Equatable {
    case executing(type: TransferDataType)
    case completed(type: TransferDataType)
    case failed
}
