// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components

public struct LeverageOption: WheelPickerDisplayable, Sendable {
    public static let allOptions: [LeverageOption] = [1, 2, 3, 5, 10, 20, 25, 30, 40, 50].map { LeverageOption(value: $0) }

    public let value: UInt8

    public init(value: UInt8) {
        self.value = value
    }

    public var id: UInt8 { value }
    public var displayText: String { "\(value)x" }
}
