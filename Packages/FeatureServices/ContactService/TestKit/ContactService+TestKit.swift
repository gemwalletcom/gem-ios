// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ContactService
import StoreTestKit

public extension ContactService {
    static func mock() -> ContactService {
        ContactService(store: .mock(), addressStore: .mock())
    }
}
