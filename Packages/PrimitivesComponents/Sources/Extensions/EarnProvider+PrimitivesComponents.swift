// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style

extension EarnProvider {
    public var image: Image {
        switch self {
        case .yo: Images.EarnProviders.yo
        }
    }

    public var displayName: String {
        switch self {
        case .yo: "Yo"
        }
    }
}
