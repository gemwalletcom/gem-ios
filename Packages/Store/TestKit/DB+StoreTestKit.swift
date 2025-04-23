// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

extension DB {
    public static func mock() -> DB {
        DB(
            directory: "DatabaseMock_\(UUID().uuidString)",
            name: "\(NSUUID().uuidString).sqlite"
        )
    }
}
