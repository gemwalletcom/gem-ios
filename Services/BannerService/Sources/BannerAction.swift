// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct BannerAction: Sendable {
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

extension BannerAction {
    public var closeOnAction: Bool {
        switch event {
        case .stake,
            .accountActivation,
            .accountBlockedMultiSignature: false
        case .enableNotifications: true
        }
    }
}
