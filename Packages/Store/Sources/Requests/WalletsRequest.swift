// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct WalletsRequest: Queryable {
    public static var defaultValue: [Wallet] { [] }
    
    private let isPinned: Bool
    public init(
        isPinned: Bool
    ) {
        self.isPinned = isPinned
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
            .filter(Columns.Wallet.isPinned == isPinned)
            .asRequest(of: WalletRecordInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToWallet() }
    }
}
