// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import BannerServiceTestKit
import StoreTestKit
import NotificationServiceTestKit
import Primitives
@testable import Store

@testable import BannerService

struct BannerServiceTests {
    @Test
    func closeBannerActions() async throws {
        let (store, bannerId, service) = try setupTest()
        let action = BannerAction(id: bannerId, type: .closeBanner, url: nil)

        try await service.handleAction(action)

        #expect(try store.getBanner(id: bannerId)?.state == .cancelled)
    }

    @Test
    func doesNotCloseBannerActions() async throws {
        let nonClosingActions: [BannerActionType] = [
            .event(.stake),
            .event(.activateAsset),
            .event(.suspiciousAsset),
            .event(.onboarding),
            .event(.accountActivation),
            .event(.accountBlockedMultiSignature),
            .button(.buy),
            .button(.receive),
        ]

        for type in nonClosingActions {
            let (store, bannerId, service) = try setupTest()
            let action = BannerAction(id: bannerId, type: type, url: nil)

            try await service.handleAction(action)

            #expect(try store.getBanner(id: bannerId)?.state == .active)
        }
    }
}

// MARK: - Private

extension BannerServiceTests {
    private func setupTest() throws -> (store: BannerStore, bannerId: String, service: BannerService) {
        let banner = NewBanner(event: .stake, state: .active)
        let store = try createStore(banner: banner)
        let bannerId = Banner(wallet: nil, asset: nil, chain: nil, event: banner.event, state: banner.state).id
        let service = BannerService.mock(store: store)
        return (store, bannerId, service)
    }

    private func createStore(banner: NewBanner) throws -> BannerStore {
        let db = DB.mock()
        let store = BannerStore.mock(db: db)
        try store.addBanners([banner])
        return store
    }
}
