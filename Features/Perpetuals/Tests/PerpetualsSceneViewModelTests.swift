// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import PerpetualsTestKit
@testable import Perpetuals

@MainActor
struct PerpetualsSceneViewModelTests {

    @Test
    func headerViewModel() {
        let wallet = Wallet.mock(type: .multicoin)
        let model = PerpetualsSceneViewModel.mock(wallet: wallet)

        #expect(model.headerViewModel.walletType == .multicoin)
    }
}
