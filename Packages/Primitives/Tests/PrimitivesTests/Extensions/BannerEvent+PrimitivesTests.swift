// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Primitives

struct BannerEventComparableTests {
    @Test
    func bannerEventSortingOrder() {
        let events: [BannerEvent] = [
            .stake,
            .accountActivation,
            .enableNotifications,
            .accountBlockedMultiSignature,
            .activateAsset,
            .suspiciousAsset,
            .onboarding
        ]
        
        let sorted = events.sorted()
        
        #expect(sorted == [
            .accountBlockedMultiSignature,
            .accountActivation,
            .activateAsset,
            .suspiciousAsset,
            .onboarding,
            .enableNotifications,
            .stake
        ])
    }
}
