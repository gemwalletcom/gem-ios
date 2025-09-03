// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Style
import SwiftUI
import Localization

public struct LatencyViewModel: Sendable {
    private let latency: Latency

    public init(latency: Latency) {
        self.latency = latency
    }
    
    public var title: String {
        Localized.Common.latencyInMs(value)
    }

    public var color: Color {
        switch latency.type {
        case .fast: Colors.green
        case .normal: Colors.orange
        case .slow: Colors.red
        }
    }

    public var background: Color {
        color.opacity(0.15)
    }

    public var value: Int {
        Int(latency.value)
    }
}
