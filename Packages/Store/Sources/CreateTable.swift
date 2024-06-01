import Foundation
import GRDB

protocol CreateTable {
    static var databaseTableName: String { get }
    static func create(db: Database) throws
}
