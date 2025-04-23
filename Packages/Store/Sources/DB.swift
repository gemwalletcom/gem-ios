import Foundation
@preconcurrency import GRDB

public struct DB: Sendable {
    private static let ignoreMethods = ["COMMIT TRANSACTION", "PRAGMA query_only", "BEGIN DEFERRED TRANSACTION"].asSet()

    public let dbQueue: DatabaseQueue

    public init(
        directory: String,
        name: String,
        configuration: GRDB.Configuration = DB.defaultConfiguration
    ) {
        do {
            dbQueue = try DatabaseQueue(
                path: DBURLResolver.resolve(
                    directory: directory,
                    fileName: name,
                ).path(percentEncoded: false),
                configuration: configuration
            )
        } catch {
            fatalError("db initialization error: \(error)")
        }

        do {
            var migrations = Migrations()
            try migrations.run(dbQueue: dbQueue)

            if !isRunningTests {
                try migrations.runChanges(dbQueue: dbQueue)
            }
        } catch {
            fatalError("db migrations error: \(error)")
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
                    //NSLog("profile SQL> \(statement)")
                case .statement(let statement):
                    let sql = statement.sql

                    if ignoreMethods.filter({ sql.description.contains($0) }).isEmpty {
                        // NSLog("SQL> \(sql)")
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
