// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum ToastEvent: Sendable, Equatable, Identifiable {
    case transfer(TransferData)

    public var id: String {
        switch self {
        case .transfer(let data): "transfer-\(data.id)"
        }
    }
}
