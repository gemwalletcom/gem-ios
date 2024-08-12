// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct WalletRequest: Queryable {
    public static var defaultValue: Wallet? { .none }
    
    let walletId: String
    
    public init(walletId: String) {
        self.walletId = walletId
    }
    
    public func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<Wallet?, Error> {
        ValueObservation
            .tracking { db in try fetch(db) }
            .publisher(in: dbQueue, scheduling: .immediate)
            .map { $0.map{ $0 } }
            .eraseToAnyPublisher()
    }
    
    private func fetch(_ db: Database) throws -> Wallet? {
        return try WalletRecord
            .including(all: WalletRecord.accounts)
            .asRequest(of: WalletRecordInfo.self)
            .filter(Columns.Wallet.id == walletId)
            .fetchOne(db)?
            .mapToWallet()
    }
}
