// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Style
import SwiftUI
import Localization

struct LatencyViewModel: Sendable {
    private let latency: Latency

    init(latency: Latency) {
        self.latency = latency
    }
    
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
