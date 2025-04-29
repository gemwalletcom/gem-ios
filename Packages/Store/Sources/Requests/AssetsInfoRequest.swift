import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AssetsInfoRequest: ValueObservationQueryable {
    public static var defaultValue: AssetsInfo { AssetsInfo(hidden: 0) }
    
    private let walletId: String

    public init(walletId: String) {
        self.walletId = walletId
    }

    public func fetch(_ db: Database) throws -> AssetsInfo {
        let hidden = try BalanceRecord
            .filter(BalanceRecord.Columns.walletId == walletId)
            .filter(BalanceRecord.Columns.isHidden == true)
            .fetchCount(db)
        return AssetsInfo(hidden: hidden)
    }
}
