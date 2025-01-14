// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import Style

struct HeaderButton: Identifiable {
    let type: HeaderButtonType
    let isEnabled: Bool
    
    var id: String { type.rawValue }
    
    var title: String {
        switch type {
        case .send: Localized.Wallet.send
        case .receive: Localized.Wallet.receive
        case .buy: Localized.Wallet.buy
        case .swap: Localized.Wallet.swap
        }
    }
    
    var image: Image {
        switch type {
        case .send: Images.Actions.send
        case .receive: Images.Actions.receive
        case .buy: Images.Actions.buy
        case .swap: Images.Actions.swap
        }
    }
}
