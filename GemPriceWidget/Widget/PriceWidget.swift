// Copyright (c). Gem Wallet. All rights reserved.

import WidgetKit
import SwiftUI

struct SmallPriceWidget: Widget {
    let kind: String = "SmallPriceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PriceWidgetProvider()) { entry in
            PriceWidgetView(entry: entry, widgetFamily: .systemSmall)
        }
        .configurationDisplayName("Bitcoin Price")
        .description("Track Bitcoin price")
        .supportedFamilies([.systemSmall])
    }
}

struct MediumPriceWidget: Widget {
    let kind: String = "MediumPriceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PriceWidgetProvider()) { entry in
            PriceWidgetView(entry: entry, widgetFamily: .systemMedium)
        }
        .configurationDisplayName("Top Crypto Prices")
        .description("Track prices of top cryptocurrencies")
        .supportedFamilies([.systemMedium])
    }
}

