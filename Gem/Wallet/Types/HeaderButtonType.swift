// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum HeaderButtonType: String, Identifiable, CaseIterable {
    case send
    case receive
    case buy
    case swap
    
    var id: String { rawValue }
}

extension HeaderButtonType {
    var selectType: SelectAssetType {
        switch self {
        case .receive: .receive(.regular)
        case .send: .send
        case .buy: .buy
        case .swap: .swap(.pay)
        }
    }
}
