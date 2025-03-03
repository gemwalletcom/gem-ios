// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapProvider
import Components

public struct SwapProviderViewModel {
    
    private let provider: SwapProvider
    
    init(provider: SwapProvider) {
        self.provider = provider
    }
    
    var providerText: String? {
        provider.name
    }
    
    var providerImage: AssetImage? {
        AssetImage(imageURL: .none, placeholder: provider.image, chainPlaceholder: .none)
    }
}
