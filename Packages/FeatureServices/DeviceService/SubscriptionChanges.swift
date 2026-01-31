// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct SubscriptionChanges: Sendable {
    public let toAdd: [WalletSubscription]
    public let walletIdsToDelete: [String]

    public init(toAdd: [WalletSubscription], walletIdsToDelete: [String]) {
        self.toAdd = toAdd
        self.walletIdsToDelete = walletIdsToDelete
    }

    public var hasChanges: Bool {
        !toAdd.isEmpty || !walletIdsToDelete.isEmpty
    }
}
