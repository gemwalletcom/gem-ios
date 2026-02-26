// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components

public struct SimpleAccount {
    public let name: String?
    public let chain: Chain
    public let address: String
    public let assetImage: AssetImage?
    public let addressType: AddressType?

    public init(name: String?, chain: Chain, address: String, assetImage: AssetImage?, addressType: AddressType? = nil) {
        self.name = name
        self.chain = chain
        self.address = address
        self.assetImage = assetImage
        self.addressType = addressType
    }
}
