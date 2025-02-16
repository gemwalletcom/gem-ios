// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import Style
import Components

public struct HeaderButton: Identifiable {
    let type: HeaderButtonType
    let isEnabled: Bool
    
    public init(
        type: HeaderButtonType,
        isEnabled: Bool
    ) {
        self.type = type
        self.isEnabled = isEnabled
    }
    
    public var id: String { type.rawValue }
    
    public var title: String {
        switch type {
        case .send: Localized.Wallet.send
        case .receive: Localized.Wallet.receive
        case .buy: Localized.Wallet.buy
        case .swap: Localized.Wallet.swap
        case .stake: Localized.Wallet.stake
        case .more: Localized.Wallet.more
        case .avatar: Localized.Common.avatar
        case .gallery: Localized.Common.photo
        case .emoji: Localized.Common.emoji
        case .nft: Localized.Nft.collections
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
        case .avatar: Images.Actions.avatar
        case .gallery: Image(systemName: SystemImage.photo)
        case .emoji: Image(systemName: SystemImage.emoji)
        case .nft: Images.Tabs.collections
        }
    }
}
