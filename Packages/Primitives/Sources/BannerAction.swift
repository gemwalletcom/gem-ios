// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct BannerAction: Identifiable, Sendable {
    public let id: String
    public let type: BannerActionType
    public let url: URL?
    
    public init(
        id: String,
        type: BannerActionType,
        url: URL?
    ) {
        self.id = id
        self.type = type
        self.url = url
    }
}

public enum BannerActionType: Sendable {
    case event(BannerEvent)
    case button(BannerButton)
    case closeBanner
}

public enum BannerButton: String, Sendable {
    case buy
    case receive
}
