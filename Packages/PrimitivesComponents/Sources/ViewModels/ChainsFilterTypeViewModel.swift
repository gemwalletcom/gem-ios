// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Foundation
import Localization
import Style

public struct ChainsFilterTypeViewModel: FilterTypeRepresentable {
    private let type: ChainsFilterType

    public init(type: ChainsFilterType) {
        self.type = type
    }

    public var value: String {
        switch type {
        case .allChains:
            Localized.Common.all
        case let .chain(chain):
            chain.rawValue.capitalized
        case let .chains(selected):
            "\(selected.count)"
        }
    }

    public var title: String {
        Localized.Settings.Networks.title
    }

    public var image: Image { Images.Settings.networks }
}
