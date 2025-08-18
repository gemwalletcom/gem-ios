// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AddressNameService
import Store
import StoreTestKit

public extension AddressNameService {
    static func mock(addressStore: AddressStore = .mock()) -> AddressNameService {
        AddressNameService(addressStore: addressStore)
    }
}