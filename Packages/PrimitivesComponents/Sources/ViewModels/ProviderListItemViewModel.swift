// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import class Gemstone.SwapProviderConfig

public struct ProviderListItemViewModel: ListItemViewModelRepresentable {
    
    private let providerId: String
    
    public init(providerId: String) {
        self.providerId = providerId
    }
    
    public var title: String {
        Localized.Common.provider
    }
    
    public var subtitle: String {
        SwapProviderConfig.fromString(id: providerId).inner().name
    }
}