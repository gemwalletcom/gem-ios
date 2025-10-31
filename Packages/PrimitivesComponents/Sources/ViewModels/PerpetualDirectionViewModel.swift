// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Style
import SwiftUI

public struct PerpetualDirectionViewModel {

    private let direction: PerpetualDirection

    public init(direction: PerpetualDirection) {
        self.direction = direction
    }

    public var title: String {
        switch direction {
        case .short: Localized.Perpetual.short
        case .long: Localized.Perpetual.long
        }
    }

    public var increaseTitle: String {
        Localized.Perpetual.increaseDirection(title)
    }

    public var reduceTitle: String {
        Localized.Perpetual.reduceDirection(title)
    }

    public var color: Color {
        switch direction {
        case .long: Colors.green
        case .short: Colors.red
        }
    }
}
