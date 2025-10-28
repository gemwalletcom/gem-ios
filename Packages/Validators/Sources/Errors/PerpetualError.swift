// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

public enum PerpetualError: Equatable {
    case invalidAutoclose(type: TpslType)
}

extension PerpetualError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidAutoclose(let type):
            switch type {
            case .takeProfit: "Trigger price should be higher than market price" // TODO: Localized
            case .stopLoss: "Trigger price should be lower than market price" // TODO: Localized
            }
        }
    }
}
