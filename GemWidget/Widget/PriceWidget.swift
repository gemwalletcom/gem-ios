// Copyright (c). Gem Wallet. All rights reserved.

import WidgetKit
import SwiftUI

struct PriceWidget: Widget {
    let kind: String = "PriceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PriceWidgetProvider()) { entry in
            PriceWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Top Crypto Prices")
        .description("Track prices of top 5 cryptocurrencies")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}