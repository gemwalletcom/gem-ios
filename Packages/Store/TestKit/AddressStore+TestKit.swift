// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives

public extension AddressStore {
    static func mock(db: DB = .mock()) -> Self {
        AddressStore(db: db)
    }
    
    static func mockAddresses(db: DB = .mock()) -> Self {
        let store = AddressStore(db: db)
        try? store.addAddressNames([
            AddressName(chain: .ethereum, address: "0x1234567890123456789012345678901234567890", name: "Ethereum"),
            AddressName(chain: .bitcoin, address: "bc1qml9s2f9k8wc0882x63lyplzp97srzg2c39fyaw", name: "Bitcoin")
        ])
        return store
    }
}
