import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct TotalValueRequest: ValueObservationQueryable {
    public static var defaultValue: Double { 0 }

    public var walletId: String
    
    public init(walletID: String) {
        self.walletId = walletID
    }

    public func fetch(_ db: Database) throws -> Double {
        //TODO: - Refactor to calculate total price
        try AssetRecord
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance)
            .joining(required: AssetRecord.balance
                .filter(Columns.Balance.walletId == walletId)
                .filter(Columns.Balance.isEnabled == true)
                .filter(Columns.Balance.fiatValue > 0)
            )
            .asRequest(of: AssetRecordInfoMinimal.self)
            .fetchAll(db)
            .map { $0.balance.total * ($0.price?.price ?? 0) }
            .reduce(0, +)
    }
}
