// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum FileStorageKey {
    case avatar(walletId: String, avatarId: String)
    
    public var path: String {
        switch self {
        case let .avatar(walletId, avatarId):
            return "avatar_\(walletId)_\(avatarId)"
        }
    }
}
