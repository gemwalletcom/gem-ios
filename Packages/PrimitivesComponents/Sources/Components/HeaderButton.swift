// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import Style
import Components

public enum HeaderButtonViewType: Identifiable {
    case button
    case menuButton(title: String? = nil, items: [ActionMenuItemType])

    public var id: String {
        switch self {
        case .button: "button"
        case let .menuButton(title, items): "\(title ?? "")_\(items.map { $0.id }.joined(separator: ","))"
        }
    }
}

public struct HeaderButton: Identifiable {
    let type: HeaderButtonType
    let viewType: HeaderButtonViewType
    let isEnabled: Bool

    public init(
        type: HeaderButtonType,
        viewType: HeaderButtonViewType = .button,
        isEnabled: Bool
    ) {
        self.type = type
        self.isEnabled = isEnabled
        self.viewType = viewType
    }
    
    public var id: String { "\(type.rawValue)_\(viewType.id)" }
    
    public var title: String {
        switch type {
        case .send: Localized.Wallet.send
        case .receive: Localized.Wallet.receive
        case .buy: Localized.Wallet.buy
        case .swap: Localized.Wallet.swap
        case .stake: Localized.Wallet.stake
        case .more: Localized.Wallet.more
        case .deposit: "Deposit"
        case .withdraw: "Withdraw"
        }
    }
    
    public var image: Image {
        switch type {
        case .send: Images.Actions.send
        case .receive: Images.Actions.receive
        case .buy: Images.Actions.buy
        case .swap: Images.Actions.swap
        case .stake: Images.Actions.swap
        case .more: Images.Actions.more
        case .deposit: Images.Actions.buy
        case .withdraw: Images.Actions.send
        }
    }
}
