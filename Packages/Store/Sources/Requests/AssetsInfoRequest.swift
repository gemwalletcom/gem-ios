import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AssetsInfoRequest: Queryable {
    public static var defaultValue: AssetsInfo { AssetsInfo(hidden: 0) }
    
    let walletId: String
    
    public init(walletId: String) {
        self.walletId = walletId
    }
    
    public func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<AssetsInfo, Error> {
        ValueObservation
            .tracking { db in try fetch(db) }
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    private func fetch(_ db: Database) throws -> AssetsInfo {
        let hidden = try AssetBalanceRecord
            .filter(Columns.Balance.walletId == walletId)
            .filter(Columns.Balance.isHidden == true)
            .fetchCount(db)
        return AssetsInfo(hidden: hidden)
    }
}
