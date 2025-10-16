// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct StakeValidatorsRequest: ValueObservationQueryable {
    public static var defaultValue: [DelegationValidator] { [] }

    private let assetId: String

    public init(assetId: String) {
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> [DelegationValidator] {
        try StakeStore.getValidatorsActive(db: db, assetId: assetId)
    }
}
