// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives

public struct SwapProviderViewModel {
    private let providerData: SwapProviderData

    public init(providerData: SwapProviderData) {
        self.providerData = providerData
    }
    
    public var providerText: String { providerData.name }

    public var providerImage: AssetImage {
        AssetImage(
            imageURL: .none,
            placeholder: providerData.provider.image,
            chainPlaceholder: .none
        )
    }
}
