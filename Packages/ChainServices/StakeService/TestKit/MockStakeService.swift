// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import StakeService
import Primitives

public struct MockStakeService: StakeServiceable {
    
    public let stakeApr: Double?
    
    public init(stakeApr: Double? = .none) {
        self.stakeApr = stakeApr
    }
    
    public func stakeApr(assetId: AssetId) throws -> Double? {
        self.stakeApr
    }
    
    public func update(walletId: String, chain: Chain, address: String) async throws {
        //
    }

    public func getValidatorsActive(assetId: AssetId) throws -> [DelegationValidator] {
        []
    }

    public func getValidator(assetId: AssetId, validatorId: String) throws -> DelegationValidator? {
        .none
    }
}
