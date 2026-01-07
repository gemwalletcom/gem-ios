// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Recents
import ActivityServiceTestKit
import StoreTestKit

public extension RecentsSceneViewModel {
    static func mock(
        walletId: WalletId = .mock(),
        types: [RecentActivityType] = [],
        onSelect: @escaping (Asset) -> Void = { _ in }
    ) -> RecentsSceneViewModel {
        RecentsSceneViewModel(
            walletId: walletId,
            types: types,
            activityService: .mock(),
            onSelect: onSelect
        )
    }
}
