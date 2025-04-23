import Foundation
@preconcurrency import GRDB

public struct DB: Sendable {
    private static let ignoreMethods = ["COMMIT TRANSACTION", "PRAGMA query_only", "BEGIN DEFERRED TRANSACTION"].asSet()
    public let dbQueue: DatabaseQueue

    public init(
        fileName: String = "db.sqlite",
        configuration: GRDB.Configuration = DB.defaultConfiguration
    ) {
        do {
            let fileManager = FileManager.default
            let oldFileUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appending(path: fileName)
            let newFileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appending(path: fileName)
            
            // Migrate db from documents to support.
            if fileManager.fileExists(atPath: oldFileUrl.path()) {
                try fileManager.moveItem(at: oldFileUrl, to: newFileUrl)
            }
            dbQueue = try DatabaseQueue(path: newFileUrl.path(percentEncoded: false), configuration: configuration)
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
