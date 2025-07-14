// Copyright (c). Gem Wallet. All rights reserved.

import WidgetKit
import SwiftUI

public struct PriceWidgetProvider: TimelineProvider {
    private let widgetPriceService = WidgetPriceService()
    
    public init() {}
    
    public func placeholder(in context: Context) -> PriceWidgetEntry {
        PriceWidgetEntry.placeholder(widgetFamily: context.family)
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (PriceWidgetEntry) -> Void) {
        if context.isPreview {
            completion(PriceWidgetEntry.placeholder(widgetFamily: context.family))
        } else {
            let entry = widgetPriceService.fetchTopCoinPrices(widgetFamily: context.family)
            completion(entry)
        }
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<PriceWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entry = widgetPriceService.fetchTopCoinPrices(widgetFamily: context.family)
        
        // Update every 15 minutes
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}
