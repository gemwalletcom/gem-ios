// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB
import os

public struct DB: Sendable {
    private static let ignoreMethods = ["COMMIT TRANSACTION", "PRAGMA query_only", "BEGIN DEFERRED TRANSACTION"].asSet()
    public let dbQueue: DatabaseQueue

    public init(
        fileName: String = "db.sqlite",
        configuration: GRDB.Configuration = DB.defaultConfiguration
    ) {
        do {
            // TODO: - remove the logic FileMigrator in 2026
            let fileMigrator = FileMigrator()
            let databaseURL = try fileMigrator.migrate(
                name: fileName,
                fromDirectory: .documentDirectory,
                toDirectory: .applicationSupportDirectory,
                isDirectory: false
            )
            dbQueue = try DatabaseQueue(path: databaseURL.path(percentEncoded: false), configuration: configuration)
        } catch {
            os_log(
                "DB Initialization error: %{public}@",
                log: .default,
                type: .fault,
                error.localizedDescription
            )
            fatalError("DB Initialization error: \(error)")
        }

        do {
            var migrations = Migrations()
            try migrations.run(dbQueue: dbQueue)
            if !isRunningTests {
                try migrations.runChanges(dbQueue: dbQueue)
            }
        } catch {
            os_log(
                "DB Migration error: %{public}@",
                log: .default,
                type: .fault,
                error.localizedDescription
            )
            fatalError("DB Migration error: \(error)")
        }
    }

    public static let defaultConfiguration: GRDB.Configuration = {
        var config = GRDB.Configuration()
        #if DEBUG
        config.publicStatementArguments = true
        config.prepareDatabase { db in
            db.trace { //sql in
                switch $0 {
                case .profile(let statement, let duration):
                    break
                    //#debugLog("profile SQL> \(statement)")
                case .statement(let statement):
                    let sql = statement.sql

                    if ignoreMethods.filter({ sql.description.contains($0) }).isEmpty {
                        // #debugLog("SQL> \(sql)")
                    }
                }
            }
        }
        #endif
        return config
    }()
}

var isRunningTests: Bool {
    return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}
