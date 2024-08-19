import Foundation
import GRDB

public class DB: ObservableObject {
    private let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    public let dbQueue: DatabaseQueue

    static let ignoreMethods = ["COMMIT TRANSACTION", "PRAGMA query_only", "BEGIN DEFERRED TRANSACTION"].asSet()

    public static var defaultConfiguration: GRDB.Configuration = {
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
                        //NSLog("SQL> \(sql)")
                    }
                }
            }
        }
        #endif
        return config
    }()

    private let dbPath: URL
    private var migrations = Migrations()

    public init(
        path: String,
        configuration: GRDB.Configuration = DB.defaultConfiguration
    ) {
        do {
            dbPath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appending(path: path)
            dbQueue = try DatabaseQueue(path: dbPath.absoluteString, configuration: configuration)
        } catch {
            fatalError("db initialization error: \(error)")
        }
        do {
            try migrations.run(dbQueue: dbQueue)
        } catch {
            fatalError("db migrations error: \(error)")
        }
    }
}
