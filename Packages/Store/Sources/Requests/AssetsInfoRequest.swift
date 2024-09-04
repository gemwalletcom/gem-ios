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
        let hidden = try AssetBalanceRecord
            .filter(Columns.Balance.walletId == walletId)
            .filter(Columns.Balance.isHidden == true)
            .fetchCount(db)
        return AssetsInfo(hidden: hidden)
    }
}
