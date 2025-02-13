// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AvatarRequest: ValueObservationQueryable {
    public static var defaultValue: AvatarValue? { nil }
    
    public let walletId: String
    
    public init(walletId: String) {
        self.walletId = walletId
    }
    
    public func fetch(_ db: Database) throws -> AvatarValue? {
        try AvatarValueRecord
            .filter(Columns.Avatar.walletId == walletId)
            .fetchOne(db)?
            .avatarValue
    }
}
