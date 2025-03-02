// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapProviderType
import Components

public struct SwapProviderViewModel {
    
    private let provider: SwapProviderType

    init(provider: SwapProviderType) {
        self.provider = provider
    }
    
    var providerText: String? {
        provider.name
    }
    
    var providerImage: AssetImage? {
        AssetImage(imageURL: .none, placeholder: provider.id.image, chainPlaceholder: .none)
    }
}
