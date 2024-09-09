// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI

struct StakeNavigationFlow: View {

    @Environment(\.stakeService) private var stakeService

    let wallet: Wallet
    let assetId: AssetId

    init(
        wallet: Wallet,
        assetId: AssetId
    ) {
        self.wallet = wallet
        self.assetId = assetId
    }

    var body: some View {
        StakeScene(
            model: StakeViewModel(
                wallet: wallet,
                chain: assetId.chain,
                stakeService: stakeService
            )
        )
    }
}
