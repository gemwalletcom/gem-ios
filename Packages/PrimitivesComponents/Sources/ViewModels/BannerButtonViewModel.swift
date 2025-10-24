// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives
import Style

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
    
    @MainActor
    var style: ColorButtonStyle {
        switch button {
        case .buy: .blue(paddingVertical: .small)
        case .receive: .empty(paddingVertical: .small)
        }
    }
    
    var action: BannerAction {
        BannerAction(id: banner.id, type: .button(button), url: nil)
    }
}
