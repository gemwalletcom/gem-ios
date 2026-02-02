// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import WalletTab

struct WalletSearchModelTests {

    @Test
    func searchMode() {
        var model = WalletSearchModel(selectType: .manage)
        #expect(model.searchMode(tag: nil) == .initial)
        #expect(model.searchMode(tag: "stablecoins") == .tagBrowsing)

        model.searchableQuery = "bitcoin"
        #expect(model.searchMode(tag: nil) == .searching)
    }

    @Test
    func assetsLimit() {
        var model = WalletSearchModel(selectType: .manage)

        #expect(model.assetsLimit(tag: nil, isPerpetualEnabled: false) == 100)
        #expect(model.assetsLimit(tag: nil, isPerpetualEnabled: true) == 12)
        #expect(model.assetsLimit(tag: "stablecoins", isPerpetualEnabled: true) == 18)

        model.searchableQuery = "bitcoin"
        #expect(model.assetsLimit(tag: nil, isPerpetualEnabled: true) == 25)
    }

    @Test
    func fetchLimit() {
        var model = WalletSearchModel(selectType: .manage)

        #expect(model.fetchLimit(tag: nil, isPerpetualEnabled: false) == 100)
        #expect(model.fetchLimit(tag: nil, isPerpetualEnabled: true) == 13)
        #expect(model.fetchLimit(tag: "stablecoins", isPerpetualEnabled: true) == 19)

        model.searchableQuery = "bitcoin"
        #expect(model.fetchLimit(tag: nil, isPerpetualEnabled: true) == 100)
    }

    @Test
    func staticMethods() {
        #expect(WalletSearchModel.initialFetchLimit(isPerpetualEnabled: false) == 100)
        #expect(WalletSearchModel.initialFetchLimit(isPerpetualEnabled: true) == 13)
        #expect(WalletSearchModel.searchItemTypes(isPerpetualEnabled: false) == [.asset])
        #expect(WalletSearchModel.searchItemTypes(isPerpetualEnabled: true) == [.asset, .perpetual])
        #expect(WalletSearchModel.recentActivityTypes(isPerpetualEnabled: false) == RecentActivityType.allCases.filter { $0 != .perpetual })
        #expect(WalletSearchModel.recentActivityTypes(isPerpetualEnabled: true) == RecentActivityType.allCases)
    }
}
