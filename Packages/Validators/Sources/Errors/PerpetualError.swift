// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

public enum PerpetualError: Equatable {
    case invalidAutoclose(type: TpslType, direction: PerpetualDirection)
}

extension PerpetualError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidAutoclose(let type, let direction):
            let comparison = switch (type, direction) {
            case (.takeProfit, .long), (.stopLoss, .short): "higher"
            case (.takeProfit, .short), (.stopLoss, .long): "lower"
            }
            return "Trigger price should be \(comparison) than market price" // TODO: Localized
        }
    }
}
