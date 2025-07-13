// Copyright (c). Gem Wallet. All rights reserved.

import WidgetKit
import SwiftUI

public struct PriceWidget: Widget {
    public let kind: String = "PriceWidget"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PriceWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                PriceWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PriceWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("Top Crypto Prices")
        .description("Track prices of top 5 cryptocurrencies")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}