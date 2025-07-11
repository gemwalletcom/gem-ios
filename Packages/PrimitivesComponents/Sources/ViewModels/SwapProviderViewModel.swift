// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import struct Gemstone.SwapProviderType

public struct SwapProviderViewModel {
    private let provider: SwapProviderType

    public init(provider: SwapProviderType) {
        self.provider = provider
    }
    
    public var providerText: String { provider.name }

    public var providerImage: AssetImage {
        AssetImage(
            imageURL: .none,
            placeholder: provider.image,
            chainPlaceholder: .none
        )
    }
}
