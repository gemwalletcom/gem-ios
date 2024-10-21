// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Style
import SwiftUI
import Localization

struct LatencyViewModel {
    
    let latency: Latency

    var title: String {
        Localized.Common.latencyInMs(value)
    }

    var color: Color {
        switch latency.type {
        case .fast: Colors.green
        case .normal: Colors.orange
        case .slow: Colors.red
        }
    }

    var background: Color {
        color.opacity(0.15)
    }

    var value: Int {
        Int(latency.value)
    }
}
