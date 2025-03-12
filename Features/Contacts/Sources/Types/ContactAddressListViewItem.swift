// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import PrimitivesComponents
import Style
import Components

public struct ContactAddressListViewItem<T>: Identifiable {
    public let id: String
    
    public let name: TextValue?
    public let address: TextValue?
    public let memo: TextValue?
    public let chain: TextValue?
    public let description: TextValue?
    public let image: ChainImage?
    public let object: T
    
    public init(
        id: String,
        name: TextValue? = nil,
        address: TextValue? = nil,
        memo: TextValue? = nil,
        chain: TextValue? = nil,
        description: TextValue? = nil,
        image: ChainImage? = nil,
        object: T
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.memo = memo
        self.chain = chain
        self.description = description
        self.image = image
        self.object = object
    }
}
