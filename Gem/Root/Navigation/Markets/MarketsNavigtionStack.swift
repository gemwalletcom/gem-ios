// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import MarketInsight
import PriceService

struct MarketsNavigationStack: View {
    
    @Environment(\.assetsService) private var assetsService
    
    var body: some View {
        MarketsScene(
            model: MarketsViewModel(
                service: MarketService(),
                assetsService: assetsService
            )
        )
    }
}
