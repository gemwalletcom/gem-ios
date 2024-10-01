// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

import SwiftUI
import Primitives

struct AmountNavigationView: View {
    
    @Environment(\.keystore) private var keystore
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
            model: AmounViewModel(
                input: input,
                wallet: wallet,
                walletsService: walletsService,
                stakeService: stakeService,
                onTransferAction: { data in
                    navigationPath.append(data)
                }
            )
        )
        .navigationDestination(for: TransferData.self) { data in
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: wallet,
                    keystore: keystore,
                    data: data,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: input.asset.chain),
                    walletsService: walletsService
                )
            )
        }
    }
}
