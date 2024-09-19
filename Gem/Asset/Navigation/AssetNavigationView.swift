// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives

struct AssetNavigationView: View {

    @Environment(\.stakeService) private var stakeService

    let wallet: Wallet
    let assetId: AssetId

    @Binding private var isPresentingAssetSelectType: SelectAssetInput?
    @Binding var navigationPath: NavigationPath
    @State private var isPresentingStaking: Bool = false

    init(
        wallet: Wallet,
        assetId: AssetId,
        isPresentingAssetSelectType: Binding<SelectAssetInput?>,
        navigationPath: Binding<NavigationPath>
    ) {
        self.wallet = wallet
        self.assetId = assetId
        _isPresentingAssetSelectType = isPresentingAssetSelectType
        _navigationPath = navigationPath
    }

    var body: some View {
        AssetScene(
            wallet: wallet,
            input: AssetSceneInput(walletId: wallet.walletId, assetId: assetId),
            isPresentingAssetSelectType: $isPresentingAssetSelectType
        )
    }
}
