// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct StakeDelegationsRequest: Queryable {
    public static var defaultValue: [Delegation] { [] }
    
    let walletId: String
    let assetId: String
    
    public init(walletId: String, assetId: String) {
        self.walletId = walletId
        self.assetId = assetId
    }
    
    public func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Delegation], Error> {
        ValueObservation
            .tracking { db in try fetch(db) }
            .publisher(in: dbQueue, scheduling: .immediate)
            .map { $0.map{ $0 } }
            .eraseToAnyPublisher()
    }
    
    private func fetch(_ db: Database) throws -> [Delegation] {
        return try StakeDelegationRecord
            .including(optional: StakeDelegationRecord.validator)
            .including(optional: StakeDelegationRecord.price)
            .filter(Columns.StakeDelegation.walletId == walletId)
            .filter(Columns.StakeDelegation.assetId == assetId)
            .order(Columns.StakeDelegation.state.asc)
            .asRequest(of: StakeDelegationInfo.self)
            .fetchAll(db)
            .map { $0.mapToDelegation() }
    }
}
