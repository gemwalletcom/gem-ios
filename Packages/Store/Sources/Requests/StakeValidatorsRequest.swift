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
        try StakeValidatorRecord
            .filter(StakeValidatorRecord.Columns.assetId == assetId)
            .filter(StakeValidatorRecord.Columns.isActive == true)
            .filter(StakeValidatorRecord.Columns.id != DelegationValidator.systemId)
            .filter(StakeValidatorRecord.Columns.id != DelegationValidator.legacySystemId)
            .filter(StakeValidatorRecord.Columns.name != "")
            .order(StakeValidatorRecord.Columns.apr.desc)
            .fetchAll(db)
            .map { $0.validator }
    }
}
