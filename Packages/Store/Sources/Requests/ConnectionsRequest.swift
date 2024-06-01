// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct ConnectionsRequest: Queryable {
    public static var defaultValue: [WalletConnection] { [] }
    
    public init() {
    }
    
    public func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[WalletConnection], Error> {
        ValueObservation
            .tracking { db in try fetch(db) }
            .publisher(in: dbQueue, scheduling: .immediate)
            .map { $0.map{ $0 } }
            .eraseToAnyPublisher()
    }
    
    private func fetch(_ db: Database) throws -> [WalletConnection] {
        return try WalletRecord
            .including(required: WalletRecord.connection)
            .asRequest(of: WalletConnectionInfo.self)
            .fetchAll(db)
            .map { $0.mapToWalletConnection() }
    }
}
