// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

struct HeaderButton: Identifiable {
    let type: HeaderButtonType
    
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
        case .send: Image(.arrowUp)
        case .receive: Image(.arrowDown)
        case .buy: Image(.buy)
        case .swap: Image(.swap)
        }
    }
}
