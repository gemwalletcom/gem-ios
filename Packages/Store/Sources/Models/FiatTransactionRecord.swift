// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct FiatTransactionRecord: Codable, FetchableRecord, PersistableRecord, Sendable {

    static let databaseTableName: String = "fiat_transactions"

    enum Columns {
        static let walletId = Column("walletId")
        static let assetId = Column("assetId")
        static let transactionType = Column("transactionType")
        static let providerId = Column("providerId")
        static let providerTransactionId = Column("providerTransactionId")
        static let status = Column("status")
        static let fiatAmount = Column("fiatAmount")
        static let fiatCurrency = Column("fiatCurrency")
        static let transactionHash = Column("transactionHash")
        static let address = Column("address")
    }

    var walletId: String
    var assetId: AssetId?
    var transactionType: FiatQuoteType
    var providerId: FiatProviderName
    var providerTransactionId: String
    var status: FiatTransactionStatus
    var fiatAmount: Double
    var fiatCurrency: String
    var transactionHash: String?
    var address: String?
}

extension FiatTransactionRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.assetId.name, .text)
            $0.column(Columns.transactionType.name, .text)
                .notNull()
            $0.column(Columns.providerId.name, .text)
                .notNull()
            $0.column(Columns.providerTransactionId.name, .text)
                .notNull()
            $0.column(Columns.status.name, .text)
                .notNull()
            $0.column(Columns.fiatAmount.name, .double)
                .notNull()
            $0.column(Columns.fiatCurrency.name, .text)
                .notNull()
            $0.column(Columns.transactionHash.name, .text)
            $0.column(Columns.address.name, .text)
            $0.primaryKey([
                Columns.walletId.name,
                Columns.providerId.name,
                Columns.providerTransactionId.name,
            ])
        }
    }
}

extension FiatTransactionRecord {
    var fiatTransaction: FiatTransaction {
        FiatTransaction(
            assetId: assetId,
            transactionType: transactionType,
            providerId: providerId,
            providerTransactionId: providerTransactionId,
            status: status,
            fiatAmount: fiatAmount,
            fiatCurrency: fiatCurrency,
            transactionHash: transactionHash,
            address: address
        )
    }
}

extension FiatTransaction {
    func record(walletId: String) -> FiatTransactionRecord {
        FiatTransactionRecord(
            walletId: walletId,
            assetId: assetId,
            transactionType: transactionType,
            providerId: providerId,
            providerTransactionId: providerTransactionId,
            status: status,
            fiatAmount: fiatAmount,
            fiatCurrency: fiatCurrency,
            transactionHash: transactionHash,
            address: address
        )
    }
}
