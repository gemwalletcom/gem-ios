// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol StakeServiceable: Sendable {
    func stakeApr(assetId: AssetId) throws -> Double?
    func update(walletId: String, chain: Chain, address: String) async throws
    func getActiveValidators(assetId: AssetId) throws -> [DelegationValidator]
    func getValidator(assetId: AssetId, validatorId: String) throws -> DelegationValidator?
}
