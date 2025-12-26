// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum AppEvent: Sendable, Equatable, Identifiable {
    case transfer(TransferData, EventPresentationType)

    public var id: String {
        switch self {
        case .transfer(let data, _): "transfer-\(data.id)"
        }
    }

    public var presentationType: EventPresentationType {
        switch self {
        case .transfer(_, let type): type
        }
    }
}
