// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import struct Gemstone.SwapperProviderType

public struct SwapProviderViewModel {
    private let provider: Gemstone.SwapperProviderType

    public init(provider: Gemstone.SwapperProviderType) {
        self.provider = provider
    }
    
    public var providerText: String? { provider.name }

    public var providerImage: AssetImage? {
        AssetImage(
            imageURL: .none,
            placeholder: provider.image,
            chainPlaceholder: .none
        )
    }
}
