import Foundation
import GRDB

public struct Migrations {
    
    var migrator = DatabaseMigrator()
    
    init(
        migrator: DatabaseMigrator = DatabaseMigrator()
    ) {
        self.migrator = migrator
    }
    
    mutating func run(dbQueue: DatabaseQueue) throws {
        migrator.registerMigration("Create all start table") { db in
            // wallet
            try WalletRecord.create(db: db)
            try AccountRecord.create(db: db)
            try AssetRecord.create(db: db)
            try AssetBalanceRecord.create(db: db)

            // asset
            try PriceRecord.create(db: db)
            try AssetLinkRecord.create(db: db)

            // transactions
            try TransactionRecord.create(db: db)
            try TransactionAssetAssociationRecord.create(db: db)
            
            // nodes
            try NodeRecord.create(db: db)
            try NodeSelectedRecord.create(db: db)
            
            // stake
            try StakeValidatorRecord.create(db: db)
            try StakeDelegationRecord.create(db: db)
            
            // connections
            try WalletConnectionRecord.create(db: db)

            // others
            try BannerRecord.create(db: db)
            try PriceAlertRecord.create(db: db)
            
            // nft
            try db.setupNFTSchema()
        }

        // delete later (after Oct 2024, as it's part of start tables)
        migrator.registerMigration("Create \(BannerRecord.databaseTableName)") { db in
            try? BannerRecord.create(db: db)
        }

        migrator.registerMigration("Add isPinned to \(WalletRecord.databaseTableName)") { db in
            try? db.alter(table: WalletRecord.databaseTableName) {
                $0.add(column: Columns.Wallet.isPinned.name, .boolean).defaults(to: false)
            }
        }

        migrator.registerMigration("Set order as index in \(WalletRecord.databaseTableName)") { db in
            try db.execute(sql: "UPDATE wallets SET \"order\" = \"index\"")
        }

        migrator.registerMigration("Create \(PriceAlertRecord.databaseTableName)") { db in
            try PriceAlertRecord.create(db: db)
        }
        
        migrator.registerMigration("Recreate \(BannerRecord.databaseTableName)") { db in
            try db.drop(table: BannerRecord.databaseTableName)
            try BannerRecord.create(db: db)
        }
        
        migrator.registerMigration("Add balances value to \(AssetBalanceRecord.databaseTableName)") { db in
            try? db.alter(table: AssetBalanceRecord.databaseTableName) {
                $0.add(column: Columns.Balance.availableAmount.name, .double).defaults(to: 0)
                $0.add(column: Columns.Balance.frozenAmount.name, .double).defaults(to: 0)
                $0.add(column: Columns.Balance.lockedAmount.name, .double).defaults(to: 0)
                $0.add(column: Columns.Balance.stakedAmount.name, .double).defaults(to: 0)
                $0.add(column: Columns.Balance.pendingAmount.name, .double).defaults(to: 0)
                $0.add(column: Columns.Balance.rewardsAmount.name, .double).defaults(to: 0)
                $0.add(column: Columns.Balance.reservedAmount.name, .double).defaults(to: 0)
                $0.addColumn(sql: AssetBalanceRecord.totalAmountSQlCreation)
            }
        }
        
        migrator.registerMigration("Add rewards to \(AssetBalanceRecord.databaseTableName)") { db in
            try? db.alter(table: AssetBalanceRecord.databaseTableName) { t in
                t.add(column: Columns.Balance.rewards.name, .text)
                    .defaults(to: "0")
            }
        }
        
        migrator.registerMigration("Add reserved to \(AssetBalanceRecord.databaseTableName)") { db in
            try? db.alter(table: AssetBalanceRecord.databaseTableName) { t in
                t.add(column: Columns.Balance.reserved.name, .text)
                    .defaults(to: "0")
            }
        }
        
        migrator.registerMigration("Add updatedAt to \(AssetBalanceRecord.databaseTableName)") { db in
            try? db.alter(table: AssetBalanceRecord.databaseTableName) { t in
                t.add(column: Columns.Balance.updatedAt.name, .date)
            }
        }
        
        migrator.registerMigration("Add isSellable to \(AssetRecord.databaseTableName)") { db in
            try? db.alter(table: AssetRecord.databaseTableName) { t in
                t.add(column: Columns.Asset.isSellable.name, .boolean)
                    .defaults(to: false)
            }
        }
        
        migrator.registerMigration("Add isStakeable to \(AssetRecord.databaseTableName)") { db in
            try? db.alter(table: AssetRecord.databaseTableName) { t in
                t.add(column: Columns.Asset.isStakeable.name, .boolean)
                    .defaults(to: false)
            }
        }
        
        migrator.registerMigration("Add rank to \(AssetRecord.databaseTableName)") { db in
            try? db.alter(table: AssetRecord.databaseTableName) { t in
                t.add(column: Columns.Asset.rank.name, .numeric).defaults(to: 0)
            }
        }
        
        migrator.registerMigration("Add isHidden to \(AssetBalanceRecord.databaseTableName)") { db in
            try? db.alter(table: AssetBalanceRecord.databaseTableName) { t in
                t.add(column: Columns.Balance.isHidden.name, .boolean)
                    .defaults(to: false)
                    .indexed()
            }
        }
        
        migrator.registerMigration("Add lastUsedAt to \(AssetBalanceRecord.databaseTableName)") { db in
            try? db.alter(table: AssetBalanceRecord.databaseTableName) { t in
                t.add(column: Columns.Balance.lastUsedAt.name, .date)
            }
        }
        
        migrator.registerMigration("Create \(AssetLinkRecord.databaseTableName)") { db in
            try? AssetLinkRecord.create(db: db)
        }
        
        migrator.registerMigration("Add market values to prices table \(PriceRecord.databaseTableName)") { db in
            try? db.alter(table: PriceRecord.databaseTableName) {
                $0.add(column: Columns.Price.marketCap.name, .double)
                $0.add(column: Columns.Price.marketCapRank.name, .integer)
                $0.add(column: Columns.Price.totalVolume.name, .double)
                $0.add(column: Columns.Price.circulatingSupply.name, .double)
                $0.add(column: Columns.Price.totalSupply.name, .double)
                $0.add(column: Columns.Price.maxSupply.name, .double)
            }
        }
        
        migrator.registerMigration("Add stakingApr to \(AssetRecord.databaseTableName)") { db in
            try? db.alter(table: AssetRecord.databaseTableName) {
                $0.add(column: Columns.Asset.stakingApr.name, .double)
            }
        }
        
        migrator.registerMigration("Update \(Columns.Balance.totalAmount.name) column") { db in
            try? db.alter(table: AssetBalanceRecord.databaseTableName) {
                $0.drop(column: Columns.Balance.totalAmount.name)
                $0.addColumn(sql: AssetBalanceRecord.totalAmountSQlCreation)
            }
        }
        
        migrator.registerMigration("Add isActive to \(AssetBalanceRecord.databaseTableName)") { db in
            try? db.alter(table: AssetBalanceRecord.databaseTableName) {
                $0.add(column: Columns.Balance.isActive.name, .boolean).defaults(to: true)
            }
        }

        try migrator.migrate(dbQueue)
    }
}
