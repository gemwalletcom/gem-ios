// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

public enum PerpetualError: Equatable {
    case invalidTakeProfitPrice(direction: PerpetualDirection)
}

extension PerpetualError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidTakeProfitPrice(let direction):
            switch direction {
            case .long:
                "Target price should be higher than mark price" // TODO: Localized
            case .short:
                "Target price should be lower than mark price" // TODO: Localized
            }
        }
    }
}
