// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct EarnProviderRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "earn_providers"

    public enum Columns {
        static let id = Column("id")
        static let chain = Column("chain")
        static let providerId = Column("providerId")
        static let name = Column("name")
        static let isActive = Column("isActive")
        static let fee = Column("fee")
        static let apy = Column("apy")
        static let providerType = Column("providerType")
    }

    public var id: String
    public var chain: String
    public var providerId: String
    public var name: String
    public var isActive: Bool
    public var fee: Double
    public var apy: Double
    public var providerType: String

    public init(
        id: String,
        chain: String,
        providerId: String,
        name: String,
        isActive: Bool,
        fee: Double,
        apy: Double,
        providerType: String
    ) {
        self.id = id
        self.chain = chain
        self.providerId = providerId
        self.name = name
        self.isActive = isActive
        self.fee = fee
        self.apy = apy
        self.providerType = providerType
    }

    static let positions = hasMany(EarnPositionRecord.self, key: "positions", using: ForeignKey(["providerId"], to: ["id"]))
}

extension EarnProviderRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.primaryKey(Columns.id.name, .text)
                .notNull()
            $0.column(Columns.chain.name, .text)
                .notNull()
            $0.column(Columns.providerId.name, .text)
                .notNull()
            $0.column(Columns.name.name, .text)
                .notNull()
                .defaults(to: "")
            $0.column(Columns.isActive.name, .boolean)
                .notNull()
                .defaults(to: true)
            $0.column(Columns.fee.name, .double)
                .notNull()
                .defaults(to: 0)
            $0.column(Columns.apy.name, .double)
                .notNull()
                .defaults(to: 0)
            $0.column(Columns.providerType.name, .text)
                .notNull()
        }
    }
}

extension EarnProviderRecord {
    public var earnProvider: EarnProvider? {
        guard let chain = Chain(rawValue: chain),
              let providerType = EarnProviderType(rawValue: providerType) else {
            return nil
        }
        return EarnProvider(
            chain: chain,
            id: providerId,
            name: name,
            isActive: isActive,
            fee: fee,
            apy: apy,
            providerType: providerType
        )
    }
}

extension EarnProvider {
    public static func recordId(chain: Chain, providerId: String) -> String {
        "\(chain.rawValue)_\(providerId)"
    }

    public func record() -> EarnProviderRecord {
        EarnProviderRecord(
            id: Self.recordId(chain: chain, providerId: id),
            chain: chain.rawValue,
            providerId: id,
            name: name,
            isActive: isActive,
            fee: fee,
            apy: apy,
            providerType: providerType.rawValue
        )
    }
}
