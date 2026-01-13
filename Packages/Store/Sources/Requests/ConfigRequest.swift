// Copyright (c). Gem Wallet. All rights reserved.

import Combine
import Foundation
import GRDB
import GRDBQuery
import Primitives

public struct ConfigRequest: ValueObservationQueryable {
    public static var defaultValue: ConfigResponse? { .none }

    public init() {}

    public func fetch(_ db: Database) throws -> ConfigResponse? {
        try ConfigRecord.fetchOne(db)?.config
    }
}
