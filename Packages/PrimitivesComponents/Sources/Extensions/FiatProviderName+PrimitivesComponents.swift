// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Style
import SwiftUI

public extension FiatProviderName {
    var image: Image {
        switch self {
        case .moonPay: Images.Fiat.moonpay
        case .transak: Images.Fiat.transak
        case .banxa: Images.Fiat.banxa
        case .mercuryo: Images.Fiat.mercuryo
        case .paybis: Images.Fiat.paybis
        case .flashnet: Images.Fiat.cashapp
        }
    }

    var displayName: String {
        switch self {
        case .moonPay: "MoonPay"
        case .transak: "Transak"
        case .banxa: "Banxa"
        case .mercuryo: "Mercuryo"
        case .paybis: "Paybis"
        case .flashnet: "Flashnet"
        }
    }
}
