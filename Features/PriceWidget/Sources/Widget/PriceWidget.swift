// Copyright (c). Gem Wallet. All rights reserved.

import WidgetKit
import SwiftUI

public struct SmallPriceWidget: Widget {
    public let kind: String = "SmallPriceWidget"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PriceWidgetProvider()) { entry in
            PriceWidgetView(entry: entry, widgetFamily: .systemSmall)
        }
        .configurationDisplayName("Bitcoin Price")
        .description("Track Bitcoin price")
        .supportedFamilies([.systemSmall])
    }
}

public struct MediumPriceWidget: Widget {
    public let kind: String = "MediumPriceWidget"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PriceWidgetProvider()) { entry in
            PriceWidgetView(entry: entry, widgetFamily: .systemMedium)
        }
        .configurationDisplayName("Top Crypto Prices")
        .description("Track prices of top cryptocurrencies")
        .supportedFamilies([.systemMedium])
    }
}

