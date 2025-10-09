// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives

public struct AddressNameService: Sendable {
    private let addressStore: AddressStore
    
    public init(addressStore: AddressStore) {
        self.addressStore = addressStore
    }
    
    public func getAddressName(chain: Chain, address: String) throws -> AddressName? {
        try addressStore.getAddressName(chain: chain, address: address)
    }
}