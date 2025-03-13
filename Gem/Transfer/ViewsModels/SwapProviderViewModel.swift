// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import PrimitivesComponents

import struct Gemstone.SwapProviderType

public struct SwapProviderViewModel {
    private let provider: SwapProviderType

    init(provider: SwapProviderType) {
        self.provider = provider
    }
    
    var providerText: String? {
        provider.name
    }
    
    var providerImage: AssetImage? {
        AssetImage(
            imageURL: .none,
            placeholder: provider.image,
            chainPlaceholder: .none
        )
    }
}
