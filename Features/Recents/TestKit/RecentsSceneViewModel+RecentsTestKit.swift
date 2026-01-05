// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Recents

public extension RecentsSceneViewModel {
    static func mock(
        walletId: String = "",
        types: [RecentActivityType] = [],
        onSelect: @escaping (Asset) -> Void = { _ in }
    ) -> RecentsSceneViewModel {
        RecentsSceneViewModel(
            walletId: walletId,
            types: types,
            onSelect: onSelect
        )
    }
}
