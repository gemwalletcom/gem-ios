// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import PrimitivesComponents
import Style
import Components

public struct ContactListViewItem<T>: Identifiable {
    public let id: String?
    
    public let name: String?
    public let address: String?
    public let memo: String?
    public let description: String?
    public let image: ChainImage?
    public let object: T
    
    public init(
        id: String?,
        name: String? = nil,
        address: String? = nil,
        memo: String? = nil,
        description: String? = nil,
        image: ChainImage? = nil,
        object: T
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.memo = memo
        self.description = description
        self.image = image
        self.object = object
    }
}
