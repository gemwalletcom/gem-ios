// Copyright (c). Gem Wallet. All rights reserved.

import WidgetKit
import SwiftUI

public struct PriceWidgetProvider: TimelineProvider {
    public init() {}
    
    public func placeholder(in context: Context) -> PriceWidgetEntry {
        PriceWidgetEntry.placeholder(widgetFamily: context.family)
    }
    
    public func getSnapshot(in context: Context, completion: @escaping @Sendable (PriceWidgetEntry) -> Void) {
        let widgetFamily = context.family
        let isPreview = context.isPreview
        
        if isPreview {
            completion(PriceWidgetEntry.placeholder(widgetFamily: widgetFamily))
        } else {
            Task.detached {
                let widgetPriceService = WidgetPriceService()
                let entry = await widgetPriceService.fetchTopCoinPrices(widgetFamily: widgetFamily)
                completion(entry)
            }
        }
    }
    
    public func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<PriceWidgetEntry>) -> Void) {
        let widgetFamily = context.family
        let currentDate = Date()
        
        Task.detached {
            let widgetPriceService = WidgetPriceService()
            let entry = await widgetPriceService.fetchTopCoinPrices(widgetFamily: widgetFamily)
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
}
