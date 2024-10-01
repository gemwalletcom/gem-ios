// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives

struct TransferNavigationStack: View {

    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.nodeService) private var nodeService

    let wallet: Wallet
    let input: AmountInput

    @State private var isPresentingScanner: AmountScene.Field?

    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            AmountNavigationView(
                input: input,
                wallet: wallet
            )
        }
    }
}
