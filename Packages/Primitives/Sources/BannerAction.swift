// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct BannerAction: Identifiable, Sendable {
    public let id: String
    public let event: BannerEvent
    public let url: URL?
    
    public init(
        id: String,
        event: BannerEvent,
        url: URL?
    ) {
        self.id = id
        self.event = event
        self.url = url
    }
}
