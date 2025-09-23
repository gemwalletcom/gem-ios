// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

struct BannerButtonViewModel: Identifiable {
    let button: BannerButton
    let banner: Banner

    var id: String {
        button.rawValue
    }

    var title: String {
        switch button {
        case .buy: Localized.Wallet.buy
        case .receive: Localized.Wallet.receive
        }
    }
    
    var action: BannerAction {
        BannerAction(id: banner.id, type: .button(button), url: nil)
    }
}
