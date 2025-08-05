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
                assetID: asset.asset.id.identifier,
                type: .token(UpdateTokenBalance(available: UpdateBalanceValue(value: "\(index)", amount: Double(index)))),
                updatedAt: .now,
                isActive: true
            )
        }
    }
}

public extension UpdateBalance {
    static func mockStake(assetId: AssetId) -> UpdateBalance {
        UpdateBalance(
            assetID: assetId.identifier,
            type: .stake(UpdateStakeBalance(
                staked: UpdateBalanceValue(value: "100", amount: 100.0),
                pending: UpdateBalanceValue(value: "0", amount: 0.0),
                frozen: UpdateBalanceValue(value: "0", amount: 0.0),
                locked: UpdateBalanceValue(value: "0", amount: 0.0),
                rewards: UpdateBalanceValue(value: "0", amount: 0.0)
            )),
            updatedAt: .now,
            isActive: true
        )
    }
}
