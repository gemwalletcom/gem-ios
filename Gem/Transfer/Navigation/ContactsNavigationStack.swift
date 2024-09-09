// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives

struct ContactsNavigationStack: View {

    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.nodeService) private var nodeService

    let wallet: Wallet
    let asset: Asset

    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            RecipientScene(
                model: RecipientViewModel(
                    wallet: wallet,
                    keystore: keystore,
                    asset: asset
                )
            )
        }
    }
}
