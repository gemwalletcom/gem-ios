// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Store
import StakeService
import StakeServiceTestKit
import PrimitivesTestKit

@testable import Staking

struct StakeViewModelTests {

    @Test
    @MainActor
    func testAprValue() throws {
        let mock = StakeViewModel.mock()
        let model = mock.model
        let assetStore = mock.assetStore

        try assetStore.add(assets: [.mock(asset: .mockTron(), properties: .mock(stakingApr: 13.5))])
        #expect(model.stakeAprValue == "13.50%")

        try assetStore.add(assets: [.mock(asset: .mockTron(), properties: .mock(stakingApr: nil))])
        #expect(model.stakeAprValue == .empty)

        try assetStore.add(assets: [.mock(asset: .mockTron(), properties: .mock(stakingApr: 0))])
        #expect(model.stakeAprValue == .empty)
    }
}

extension StakeViewModel {
    static func mock() -> (model: StakeViewModel, assetStore: AssetStore) {
        let db: DB = .mock()
        let assetStore: AssetStore = .mock(db: db)
        let stakeStore: StakeStore = .mock(db: db)
        let stakeService: StakeService = .mock(
            store: stakeStore
        )
        let model = StakeViewModel(
            wallet: .mock(),
            chain: .tron,
            stakeService: stakeService,
            onTransferAction: nil,
            onAmountInputAction: nil
        )
        return (model, assetStore)
    }
}
