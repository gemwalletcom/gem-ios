// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum BalanceActionType: Sendable {
    case privacyToggle
    case action(@MainActor @Sendable () -> Void)
    case none
}
