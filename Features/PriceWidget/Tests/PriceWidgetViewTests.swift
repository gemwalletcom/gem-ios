// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import PriceWidget
import PriceWidgetTestKit
import SwiftUI

struct PriceWidgetViewTests {
    
    @Test
    func emptyState() {
        let entry = PriceWidgetEntry.empty()
        let view = PriceWidgetView(entry: entry)
        
        // View should be created without crashing
        _ = view.body
    }
    
    @Test
    func withPrices() {
        let entry = PriceWidgetEntry.placeholder()
        let view = PriceWidgetView(entry: entry)
        
        // View should be created without crashing
        _ = view.body
    }
}