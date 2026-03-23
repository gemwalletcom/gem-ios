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
        static let value = Column("value")
        static let transactionHash = Column("transactionHash")
        static let address = Column("address")
        static let createdAt = Column("createdAt")
        static let updatedAt = Column("updatedAt")
        static let detailsUrl = Column("detailsUrl")
    }

    var walletId: String
    var assetId: AssetId
    var transactionType: FiatQuoteType
    var providerId: FiatProviderName
    var providerTransactionId: String?
    var status: FiatTransactionStatus
    var fiatAmount: Double
    var fiatCurrency: String
    var value: String
    var transactionHash: String?
    var address: String?
    var createdAt: Date
    var updatedAt: Date
    var detailsUrl: String?
    
    static let asset = belongsTo(AssetRecord.self, using: ForeignKey(["assetId"], to: ["id"]))
}

extension FiatTransactionRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.assetId.name, .text)
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.transactionType.name, .text)
                .notNull()
            $0.column(Columns.providerId.name, .text)
                .notNull()
            $0.column(Columns.providerTransactionId.name, .text)
            $0.column(Columns.status.name, .text)
                .notNull()
            $0.column(Columns.fiatAmount.name, .double)
                .notNull()
            $0.column(Columns.fiatCurrency.name, .text)
                .notNull()
            $0.column(Columns.value.name, .text)
                .notNull()
            $0.column(Columns.transactionHash.name, .text)
            $0.column(Columns.address.name, .text)
            $0.column(Columns.createdAt.name, .date)
                .notNull()
            $0.column(Columns.updatedAt.name, .date)
                .notNull()
            $0.column(Columns.detailsUrl.name, .text)
            $0.primaryKey([
                Columns.walletId.name,
                Columns.providerId.name,
                Columns.assetId.name
            ])
        }
    }
}

struct FiatTransactionRecordInfo: FetchableRecord, Codable {
    var fiatTransaction: FiatTransactionRecord
    var asset: AssetRecord
}

extension FiatTransactionRecordInfo {
    func map() -> FiatTransactionInfo {
        FiatTransactionInfo(
            transaction: FiatTransaction(
                assetId: fiatTransaction.assetId,
                transactionType: fiatTransaction.transactionType,
                providerId: fiatTransaction.providerId,
                providerTransactionId: fiatTransaction.providerTransactionId,
                status: fiatTransaction.status,
                fiatAmount: fiatTransaction.fiatAmount,
                fiatCurrency: fiatTransaction.fiatCurrency,
                value: fiatTransaction.value,
                transactionHash: fiatTransaction.transactionHash,
                address: fiatTransaction.address,
                createdAt: fiatTransaction.createdAt,
                updatedAt: fiatTransaction.updatedAt
            ),
            asset: asset.mapToAsset(),
            detailsUrl: fiatTransaction.detailsUrl
        )
    }
}

extension FiatTransactionInfo {
    func record(walletId: String) -> FiatTransactionRecord {
        FiatTransactionRecord(
            walletId: walletId,
            assetId: transaction.assetId,
            transactionType: transaction.transactionType,
            providerId: transaction.providerId,
            providerTransactionId: transaction.providerTransactionId,
            status: transaction.status,
            fiatAmount: transaction.fiatAmount,
            fiatCurrency: transaction.fiatCurrency,
            value: transaction.value,
            transactionHash: transaction.transactionHash,
            address: transaction.address,
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt,
            detailsUrl: detailsUrl
        )
    }
}
