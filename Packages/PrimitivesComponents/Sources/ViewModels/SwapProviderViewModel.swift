// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import struct Gemstone.SwapperProviderType

public struct SwapProviderViewModel {
    private let provider: SwapperProviderType

    public init(provider: SwapperProviderType) {
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
