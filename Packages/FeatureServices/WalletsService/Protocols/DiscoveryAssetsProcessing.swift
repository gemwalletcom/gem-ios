// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Preferences

protocol DiscoveryAssetsProcessing: Sendable {
    func discoverAssets(for walletId: WalletId, preferences: WalletPreferences) async throws
}
