import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct TotalValueRequest: Queryable {
    public static var defaultValue: WalletFiatValue { WalletFiatValue.empty }
    
    public var walletId: String
    
    public init(
        walletID: String
    ) {
        self.walletId = walletID
    }
    
    public func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<WalletFiatValue, Error> {
        ValueObservation
            .tracking { db in try fetch(db) }
            // The `.immediate` scheduling feeds the view right on subscription,
            // and avoids an initial rendering with an empty list:
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    private func fetch(_ db: Database) throws -> WalletFiatValue {
        let request = try AssetRecord
            .filter(literal: SQL(stringLiteral: "balances.walletId = '\(walletId)'"))
            .filter(literal: SQL(stringLiteral: "balances.isEnabled = true"))
            .filter(literal: SQL(stringLiteral: "balances.fiatValue > 0"))
            .including(optional: AssetRecord.price)
            .including(
                optional: AssetRecord.balance
// TODO: SQL
//                    .filter(Columns.Balance.walletId == walletId)
//                    .filter(Columns.Balance.isEnabled == true)
//                    .filter(Columns.Balance.fiatValue > 0)
            )
            .asRequest(of: AssetRecordInfoMinimal.self)
            .fetchAll(db)
       
        let totalValue = request.reduce(0) { partialResult, record in
            partialResult + (record.balance.total * (record.price?.price ?? 0))
        }
        
        let totalPrice = request.reduce(0) { partialResult, record in
            let value = (record.balance.total * (record.price?.price ?? 0))
            return partialResult + (value * (record.price?.priceChangePercentage24h ?? 0) / 100)
        }
        
        let priceChange = (100 * totalPrice) / totalValue
        
        return WalletFiatValue(
            totalValue: totalValue,
            price: totalPrice,
            priceChangePercentage24h: priceChange.isNaN ? 0 : priceChange
        )
    }
}
