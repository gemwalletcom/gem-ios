// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Preferences

public struct PerpetualNodeService: NodeURLFetchable {
    private let preferences: Preferences

    public init(preferences: Preferences) {
        self.preferences = preferences
    }

    public func node(for chain: Chain) -> URL {
        guard let url = preferences.perpetualNodeUrl?.asURL else {
            return chain.defaultWebSocketUrl
        }
        return url
    }
}
