// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Foundation
import Localization
import Style

struct ChainsFilterTypeViewModel {
    private let type: ChainsFilterType

    init(type: ChainsFilterType) {
        self.type = type
    }

    var value: String {
        switch type {
        case .allChains:
            Localized.Common.all
        case let .chain(chain):
            chain.rawValue.capitalized
        case let .chains(selected):
            "\(selected.count)"
        }
    }

    var title: String {
        Localized.Settings.Networks.title
    }

    var chainsImage: Image { Images.Settings.networks }
}
