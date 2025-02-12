// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum PrivacyLockStatus: String {
    case enabled
    case disabled

    init(enabled: Bool) {
        self = enabled ? .enabled : .disabled
    }
}
