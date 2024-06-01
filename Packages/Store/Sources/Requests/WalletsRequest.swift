// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct WalletsRequest: Queryable {
    public static var defaultValue: [Wallet] { [] }
    
    public init() {
    }
    
    public func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Wallet], Error> {
        ValueObservation
            .tracking { db in try fetch(db) }
            .publisher(in: dbQueue, scheduling: .immediate)
            .map { $0.map{ $0 } }
            .eraseToAnyPublisher()
    }
    
    private func fetch(_ db: Database) throws -> [Wallet] {
        return try WalletRecord
            .including(all: WalletRecord.accounts)
            .asRequest(of: WalletRecordInfo.self)
            .fetchAll(db)
            .map { $0.mapToWallet() }
    }
}
