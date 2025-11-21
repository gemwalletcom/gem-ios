// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

extension PerpetualPositionAction {
    public var transferData: PerpetualTransferData {
        switch self {
        case .open(let data): return data
        case .reduce(let data, _, _, _): return data
        case .increase(let data): return data
        }
    }
}
