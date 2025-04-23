// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

import SwiftUI
import Primitives
import Transfer

struct AmountNavigationView: View {
    @Environment(\.walletsService) private var walletsService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.nodeService) private var nodeService

    let input: AmountInput
    let wallet: Wallet

    @Binding private var navigationPath: NavigationPath

    init(
        input: AmountInput,
        wallet: Wallet,
        navigationPath: Binding<NavigationPath>
    ) {
        self.input = input
        self.wallet = wallet
        _navigationPath = navigationPath
    }

    var body: some View {
        AmountScene(
            model: AmountViewModel(
                input: input,
                wallet: wallet,
                walletsService: walletsService,
                stakeService: stakeService,
                onTransferAction: {
                    navigationPath.append($0)
                }
            )
        )
    }
}
