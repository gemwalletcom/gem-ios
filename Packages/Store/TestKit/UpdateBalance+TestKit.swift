// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import PrimitivesTestKit

public extension Array where Element == UpdateBalance {
    static func mock(assets: [AssetBasic] = .mock()) -> Self {
        assets.enumerated().compactMap { index, asset in
            // skip the first asset to avoid having all mocks with a balance
            guard index > 0 else { return nil }
            return UpdateBalance(
                assetId: asset.asset.id,
                type: .token(UpdateTokenBalance(available: UpdateBalanceValue(value: "\(index)", amount: Double(index)))),
                updatedAt: .now,
                isActive: true
            )
        }
    }
}
