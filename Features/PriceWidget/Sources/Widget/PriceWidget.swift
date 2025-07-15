// Copyright (c). Gem Wallet. All rights reserved.

import WidgetKit
import SwiftUI

public struct PriceWidget: Widget {
    public let kind: String = "PriceWidget"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PriceWidgetProvider()) { entry in
            PriceWidgetView(entry: entry, widgetFamily: entry.widgetFamily)
        }
        .configurationDisplayName("Top Crypto Prices")
        .description("Track prices of top cryptocurrencies")
        .supportedFamilies([.systemMedium])
    }
}
