// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct ConnectionsRequest: ValueObservationQueryable {
    public static var defaultValue: [WalletConnection] { [] }
    
    public init() {}

    public func fetch(_ db: Database) throws -> [WalletConnection] {
        try WalletRecord
            .including(required: WalletRecord.connection)
            .asRequest(of: WalletConnectionInfo.self)
            .fetchAll(db)
            .map { $0.mapToWalletConnection() }
    }
}
