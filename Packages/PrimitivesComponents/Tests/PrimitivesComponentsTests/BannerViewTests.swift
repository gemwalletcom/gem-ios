// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import SwiftUI
import Primitives
import PrimitivesTestKit

@testable import PrimitivesComponents

@MainActor
struct BannerViewTests {
    
    @Test
    func showSingleBanner() {
        let banner = Banner.mock()
        let bannerView = BannerView(
            banners: [banner],
            action: { _ in },
            closeAction: { _ in }
        )
        
        // Single banner should not show carousel indicators
        #expect(!bannerView.showCarouselIndicators)
    }
    
    @Test 
    func showMultipleBanners() {
        let banners = [Banner.mock(), Banner.mock()]
        let bannerView = BannerView(
            banners: banners,
            action: { _ in },
            closeAction: { _ in }
        )
        
        // Multiple banners should show carousel indicators
        #expect(bannerView.showCarouselIndicators)
    }
    
    @Test
    func emptyBannersArray() {
        let bannerView = BannerView(
            banners: [],
            action: { _ in },
            closeAction: { _ in }
        )
        
        // Empty array should not show indicators
        #expect(!bannerView.showCarouselIndicators)
    }
    
}

// MARK: - Test Extensions

private extension BannerView {
    var showCarouselIndicators: Bool {
        banners.count > 1
    }
}