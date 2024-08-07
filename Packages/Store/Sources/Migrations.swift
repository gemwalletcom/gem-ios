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
        migrator = migrator.disablingDeferredForeignKeyChecks()
        
        migrator.registerMigration("Create all start table") { db in
            try AssetRecord.create(db: db)
            try PriceRecord.create(db: db)
            try WalletRecord.create(db: db)
            try AccountRecord.create(db: db)
            try AssetBalanceRecord.create(db: db)
        }
        
        migrator.registerMigration("Create \(TransactionRecord.databaseTableName)") { db in
            try TransactionRecord.create(db: db)
            try TransactionAssetAssociationRecord.create(db: db)
        }
        migrator.registerMigration("Create \(NodeRecord.databaseTableName)") { db in
            try NodeRecord.create(db: db)
        }
        migrator.registerMigration("Create \(NodeSelectedRecord.databaseTableName)") { db in
            try NodeSelectedRecord.create(db: db)
        }
        
        migrator.registerMigration("Add isHidden to \(AssetBalanceRecord.databaseTableName)") { db in
            try? db.alter(table: AssetBalanceRecord.databaseTableName) { t in
                t.add(column: "isHidden", .boolean)
                    .defaults(to: false)
                    .indexed()
            }
        }
        
        migrator.registerMigration("Add index to \(WalletRecord.databaseTableName)") { db in
            try? db.alter(table: WalletRecord.databaseTableName) { t in
                t.add(column: "index", .numeric)
                    .notNull()
                    .defaults(to: 0)
            }
        }
        
        migrator.registerMigration("Add isStakeable to \(AssetRecord.databaseTableName)") { db in
            try? db.alter(table: AssetRecord.databaseTableName) { t in
                t.add(column: "isStakeable", .boolean)
                    .defaults(to: false)
            }
        }
        
        migrator.registerMigration("Drop assets_details") { db in
            try? db.drop(table: "assets_details")
        }
        
        migrator.registerMigration("Create \(AssetDetailsRecord.databaseTableName) v1") { db in
            try? db.drop(table: "assets_details_v2")
            try? db.drop(table: AssetDetailsRecord.databaseTableName)
            try AssetDetailsRecord.create(db: db)
        }
        
        migrator.registerMigration("Create \(WalletConnectionRecord.databaseTableName)") { db in
            try WalletConnectionRecord.create(db: db)
        }
        
        migrator.registerMigration("Add chains to \(WalletConnectionRecord.databaseTableName)") { db in
            try? db.alter(table: WalletConnectionRecord.databaseTableName) { t in
                t.add(column: "chains", .jsonText)
            }
        }
        
        migrator.registerMigration("Drop transactions_v10") { db in
            try? db.execute(sql: "DELETE FROM balances WHERE assetId in ('ethereum_0x76A797A59Ba2C17726896976B7B3747BfD1d220f')")
            try? db.drop(table: "transactions_v10")
        }
        
        migrator.registerMigration("Add rank to \(AssetRecord.databaseTableName)") { db in
            try? db.alter(table: AssetRecord.databaseTableName) { t in
                t.add(column: "rank", .numeric).defaults(to: 0)
            }
        }
        
        migrator.registerMigration("Add isSellable to \(AssetRecord.databaseTableName)") { db in
            try? db.alter(table: AssetRecord.databaseTableName) { t in
                t.add(column: "isSellable", .boolean)
                    .defaults(to: false)
            }
        }
        
        migrator.registerMigration("Add rewards to \(AssetBalanceRecord.databaseTableName)") { db in
            try? db.alter(table: AssetBalanceRecord.databaseTableName) { t in
                t.add(column: "rewards", .text)
                    .defaults(to: "0")
            }
        }

        migrator.registerMigration("Delete ARBITRUM type") { db in
            try db.execute(sql: "Delete from assets where type = 'ARBITRUM'")
        }
        
        migrator.registerMigration("Delete ripple chain type") { db in
            try? db.execute(sql: "delete from assets where id = 'ripple'")
            try? db.execute(sql: "delete from balances where assetId = 'ripple'")
            try? db.execute(sql: "delete from wallets_accounts where chain = 'ripple'")
            try? db.execute(sql: "delete from nodes_v1 where chain = 'ripple'")
        }
        
        migrator.registerMigration("Create \(StakeValidatorRecord.databaseTableName)") { db in
            try? db.drop(table: StakeValidatorRecord.databaseTableName)
            try StakeValidatorRecord.create(db: db)
        }
        
        migrator.registerMigration("Create \(StakeDelegationRecord.databaseTableName) v1") { db in
            try? db.drop(table: StakeDelegationRecord.databaseTableName)
            try StakeDelegationRecord.create(db: db)
        }
        
        migrator.registerMigration("Delete transactions_v14") { db in
            try? db.drop(table: "transactions_v14")
            try? db.drop(table: "transactions_v14_assets")
            
            try? db.drop(table: "transactions_v15")
            try? db.drop(table: "transactions_v15_assets")
            
            try? db.drop(table: "transactions_v16")
            try? db.drop(table: "transactions_v16_assets")
            try? db.drop(table: "transactions_v16_wallets")
        }
        
        migrator.registerMigration("Refactor staking delegations") { db in
            try? db.drop(table: StakeValidatorRecord.databaseTableName)
            try? db.drop(table: StakeDelegationRecord.databaseTableName)
            
            try StakeValidatorRecord.create(db: db)
            try StakeDelegationRecord.create(db: db)
        }
        
        migrator.registerMigration("Drop nodes tables") { db in
            try? db.drop(table: "nodes_selected_v1")
            try? db.drop(table: "nodes_v1")
            
            try? db.drop(table: "nodes_selected")
            try? db.drop(table: "nodes")
        }
        
        migrator.registerMigration("Create \(NodeRecord.databaseTableName) - \(NodeSelectedRecord.databaseTableName) ") { db in
            try NodeRecord.create(db: db)
            try NodeSelectedRecord.create(db: db)
        }

        migrator.registerMigration("Delete bnb beacon chain") { db in
            try? db.execute(sql: "delete from balances where assetId like 'binance%'")
            try? db.execute(sql: "delete from assets_details where assetId like 'binance%'")
            try? db.execute(sql: "delete from prices where assetId like 'binance%'")
            try? db.execute(sql: "delete from assets where chain = 'binance'")
            try? db.execute(sql: "delete from wallets_accounts where chain = 'binance'")
        }
        
        migrator.registerMigration("Add reserved to \(AssetBalanceRecord.databaseTableName)") { db in
            try? db.alter(table: AssetBalanceRecord.databaseTableName) { t in
                t.add(column: "reserved", .text)
                    .defaults(to: "0")
            }
        }
        
        migrator.registerMigration("Add updatedAt to \(AssetBalanceRecord.databaseTableName)") { db in
            try? db.alter(table: AssetBalanceRecord.databaseTableName) { t in
                t.add(column: "updatedAt", .date)
            }
        }

        migrator.registerMigration("Add shares column to \(StakeDelegationRecord.databaseTableName)") { db in
            try? db.alter(table: StakeDelegationRecord.databaseTableName, body: { t in
                t.add(column: "shares", .text)
            })
        }

        migrator.registerMigration("Create \(BannerRecord.databaseTableName)") { db in
            try BannerRecord.create(db: db)
        }

        try migrator.migrate(dbQueue)
    }
}
