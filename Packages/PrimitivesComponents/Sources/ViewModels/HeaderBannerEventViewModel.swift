// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct HeaderBannerEventViewModel {
    
    private let events: [BannerEvent]
    
    private let disabledEvents: Set<BannerEvent> = [.activateAsset, .accountBlockedMultiSignature]
    
    public init(events: [BannerEvent]) {
        self.events = events
    }
    
    public var isButtonsEnabled: Bool {
        !events.contains(where: { disabledEvents.contains($0) })
    }
}
