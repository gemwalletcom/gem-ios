// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Localization

struct PriceAlertsSections {
    let autoAlerts: [PriceAlertData]
    let manualAlerts: [Asset: [PriceAlertData]]
    
    var list: [ListItemValueSection<PriceAlertData>] {
        let autoSection = ListItemValueSection(
            section: "",
            footer: Localized.PriceAlerts.autoFooter,
            values: autoAlerts.map { ListItemValue(value: $0) }
        )

        let manualSections = manualAlerts
            .map { asset, alerts in
                ListItemValueSection(
                    section: asset.name,
                    values: alerts.map { ListItemValue(value: $0) }
                )
            }
            .sorted { $0.id < $1.id }

        return [autoSection] + manualSections
    }
}
