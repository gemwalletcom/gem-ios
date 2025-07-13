// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import PriceWidget
import WidgetKit

struct PriceWidgetProviderTests {
    
    @Test
    func placeholder() {
        let provider = PriceWidgetProvider()
        let context = TimelineProviderContext(environmentVariant: .lock, displaySize: CGSize(width: 300, height: 300), isPreview: true)
        
        let entry = provider.placeholder(in: context)
        
        #expect(entry.coinPrices.count == 5)
        #expect(entry.currency == "USD")
    }
    
    @Test
    func snapshotInPreview() async {
        let provider = PriceWidgetProvider()
        let context = TimelineProviderContext(environmentVariant: .lock, displaySize: CGSize(width: 300, height: 300), isPreview: true)
        
        await withCheckedContinuation { continuation in
            provider.getSnapshot(in: context) { entry in
                // In preview mode, should return placeholder
                #expect(entry.coinPrices.count == 5)
                continuation.resume()
            }
        }
    }
}