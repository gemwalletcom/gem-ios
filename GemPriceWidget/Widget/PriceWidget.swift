// Copyright (c). Gem Wallet. All rights reserved.

import WidgetKit
import SwiftUI
import WidgetLocalization

struct SmallPriceWidget: Widget {
    let kind: String = "SmallPriceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PriceWidgetProvider()) { entry in
            PriceWidgetView(entry: entry, widgetFamily: .systemSmall)
        }
        .configurationDisplayName(WidgetLocalized.Widget.Small.name)
        .description(WidgetLocalized.Widget.Small.description)
        .supportedFamilies([.systemSmall])
    }
}

struct MediumPriceWidget: Widget {
    let kind: String = "MediumPriceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PriceWidgetProvider()) { entry in
            PriceWidgetView(entry: entry, widgetFamily: .systemMedium)
        }
        .configurationDisplayName(WidgetLocalized.Widget.Medium.name)
        .description(WidgetLocalized.Widget.Medium.description)
        .supportedFamilies([.systemMedium])
    }
}

