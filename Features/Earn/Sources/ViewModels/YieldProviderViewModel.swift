// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style

public struct YieldProviderViewModel {

    public let provider: YieldProvider

    public init(provider: YieldProvider) {
        self.provider = provider
    }

    public var image: Image {
        switch provider {
        case .yo: Images.EarnProviders.yo
        }
    }

    public var displayName: String {
        switch provider {
        case .yo: "Yo"
        }
    }
}
