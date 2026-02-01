// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct SubscriptionChanges: Sendable {
    public let toAdd: [WalletSubscription]
    public let toDelete: [WalletSubscriptionChains]

    public init(toAdd: [WalletSubscription], toDelete: [WalletSubscriptionChains]) {
        self.toAdd = toAdd
        self.toDelete = toDelete
    }

    public var hasChanges: Bool {
        !toAdd.isEmpty || !toDelete.isEmpty
    }
}
