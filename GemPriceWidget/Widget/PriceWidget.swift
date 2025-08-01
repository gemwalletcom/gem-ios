// Copyright (c). Gem Wallet. All rights reserved.

import WidgetKit
import SwiftUI
import Localization

struct SmallPriceWidget: Widget {
    let kind: String = "SmallPriceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PriceWidgetProvider()) { entry in
            PriceWidgetView(entry: entry, widgetFamily: .systemSmall)
        }
        .configurationDisplayName(Localized.Widget.Small.name)
        .description(Localized.Widget.Small.description)
        .supportedFamilies([.systemSmall])
    }
}

struct MediumPriceWidget: Widget {
    let kind: String = "MediumPriceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PriceWidgetProvider()) { entry in
            PriceWidgetView(entry: entry, widgetFamily: .systemMedium)
        }
        .configurationDisplayName(Localized.Widget.Medium.name)
        .description(Localized.Widget.Medium.description)
        .supportedFamilies([.systemMedium])
    }
}

