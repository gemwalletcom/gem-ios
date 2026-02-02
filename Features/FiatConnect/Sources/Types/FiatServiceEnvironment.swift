// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import GemAPI

public extension EnvironmentValues {
    @Entry var fiatService: any GemAPIFiatService = GemAPIService()
}
