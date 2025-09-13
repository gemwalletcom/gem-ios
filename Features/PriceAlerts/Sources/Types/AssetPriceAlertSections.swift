// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct AssetPriceAlertSections {
    let auto: PriceAlertItemViewModel?
    let active: [PriceAlertItemViewModel]
    let passed: [PriceAlertItemViewModel]
    
    init(from priceAlerts: [PriceAlertData]) {
        var auto: PriceAlertItemViewModel?
        var active: [PriceAlertItemViewModel] = []
        var passed: [PriceAlertItemViewModel] = []
        
        for priceAlert in priceAlerts {
            let viewModel = PriceAlertItemViewModel(data: priceAlert)
            
            if priceAlert.priceAlert.type == .auto {
                auto = viewModel
            } else {
                if priceAlert.priceAlert.shouldDisplay {
                    active.append(viewModel)
                }
                if priceAlert.priceAlert.lastNotifiedAt != nil {
                    passed.append(viewModel)
                }
            }
        }
        
        self.auto = auto
        self.active = active
        self.passed = passed
    }
    
    var isEmpty: Bool {
        auto == nil && active.isEmpty && passed.isEmpty
    }
    
    var passedGroupedByDate: [Date: [PriceAlertItemViewModel]] {
        Dictionary(grouping: passed, by: { viewModel in
            guard let lastNotifiedAt = viewModel.data.priceAlert.lastNotifiedAt else { return Date.distantPast }
            return Calendar.current.startOfDay(for: lastNotifiedAt)
        })
    }
    
    var passedHeaders: [Date] {
        passedGroupedByDate.map({ $0.key }).filter { $0 != Date.distantPast }.sorted(by: >)
    }
}
