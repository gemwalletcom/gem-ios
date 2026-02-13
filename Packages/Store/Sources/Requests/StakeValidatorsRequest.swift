// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct StakeValidatorsRequest: DatabaseQueryable {

    private let assetId: AssetId

    public init(assetId: AssetId) {
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> [DelegationValidator] {
        try StakeStore.getValidatorsActive(db: db, assetId: assetId)
    }
}

extension StakeValidatorsRequest: Equatable {}
