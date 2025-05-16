// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import PrimitivesTestKit

public extension Array where Element == UpdateBalance {
    static func mock(assets: [AssetBasic] = .mock()) -> Self {
        assets.enumerated().compactMap { index, asset in
            guard index > 0 else { return nil }
            return UpdateBalance(
                assetID: asset.asset.id.identifier,
                type: .token(UpdateTokenBalance(available: UpdateBalanceValue(value: "\(index)", amount: Double(index)))),
                updatedAt: .now,
                isActive: true
            )
        }
    }
}
