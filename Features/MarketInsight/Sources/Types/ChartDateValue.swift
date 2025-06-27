// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct ChartDateValue: Sendable {
    public let date: Date
    public let value: Double

    public init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}
