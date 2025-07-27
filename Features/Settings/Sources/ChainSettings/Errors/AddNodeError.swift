// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization

public enum AddNodeError: LocalizedError {
    case invalidNetworkId
    case invalidURL
    
    public var errorDescription: String? {
        switch self  {
        case .invalidURL: Localized.Errors.invalidUrl
        case .invalidNetworkId: Localized.Errors.invalidNetworkId
        }
    }
}
