// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum HeaderButtonType: String, Identifiable, CaseIterable {
    case send
    case receive
    case buy
    case sell
    case swap
    
    var id: String { rawValue }
}

extension HeaderButtonType {
    var selectType: SelectAssetType {
        switch self {
        case .receive: .receive
        case .send: .send
        case .buy: .buy
        case .sell: .sell
        case .swap: .swap(.pay)
        }
    }
}
