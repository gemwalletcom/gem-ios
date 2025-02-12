// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum LockSceneState: Sendable {
    case idle
    case unlocking
    case unlocked
    case locked
    case lockedCanceled
}
