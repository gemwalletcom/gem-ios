// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct StakeValidatorRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static let databaseTableName: String = "stake_validators"

    public var id: String
    public var assetId: AssetId
    public var validatorId: String
    public var name: String
    public var isActive: Bool
    public var commission: Double
    public var apr: Double
}

extension StakeValidatorRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) {
            $0.primaryKey("id", .text)
                .notNull()
                .indexed()
            $0.column("assetId", .text)
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column("validatorId", .text)
                .notNull()
            $0.column("name", .text)
                .notNull()
            $0.column("isActive", .boolean)
                .notNull()
            $0.column("commission", .double)
                .notNull()
            $0.column("apr", .double)
                .notNull()
        }
    }
}

extension StakeValidatorRecord {
    var validator: DelegationValidator {
        DelegationValidator(
            chain: assetId.chain,
            id: validatorId,
            name: name,
            isActive: isActive,
            commision: commission,
            apr: apr
        )
    }
}

extension DelegationValidator {
    static func recordId(chain: Chain, validatorId: String) -> String {
        return "\(chain.rawValue)_\(validatorId)"
    }
}

extension DelegationValidator {
    var record: StakeValidatorRecord {
        StakeValidatorRecord(
            id: DelegationValidator.recordId(chain: chain, validatorId: id),
            assetId: chain.assetId,
            validatorId: id,
            name: name,
            isActive: isActive,
            commission: commision,
            apr: apr
        )
    }
}
