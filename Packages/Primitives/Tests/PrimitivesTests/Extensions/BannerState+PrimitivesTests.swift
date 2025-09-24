// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Primitives

struct BannerStateComparableTests {
    
    @Test
    func bannerStateSorting() {
        let alwaysActive = BannerState.alwaysActive
        let active = BannerState.active
        let cancelled = BannerState.cancelled
        
        #expect(alwaysActive < active)
        #expect(active < cancelled)
        #expect(alwaysActive < cancelled)
    }
    
    @Test
    func bannerStateSortPriority() {
        let banners = [
            BannerState.cancelled,
            BannerState.active,
            BannerState.alwaysActive
        ]
        
        let sorted = banners.sorted { $0 < $1 }
        
        #expect(sorted[0] == .alwaysActive)
        #expect(sorted[1] == .active)
        #expect(sorted[2] == .cancelled)
    }
}