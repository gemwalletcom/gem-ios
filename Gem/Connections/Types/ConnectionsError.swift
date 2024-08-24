// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum ConnectionsError: LocalizedError {
    case userCancelled

    var errorDescription: String? {
        switch self {
        case .userCancelled: Localized.Errors.Connections.userCancelled
        }
    }
}
