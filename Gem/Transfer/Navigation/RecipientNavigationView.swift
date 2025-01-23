// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Transfer
import ChainService

struct RecipientNavigationView: View {

    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService
    
    let wallet: Wallet
    let asset: Asset
    private let onComplete: VoidAction

    @Binding private var navigationPath: NavigationPath
    
    init(
        wallet: Wallet,
        asset: Asset,
        navigationPath: Binding<NavigationPath>,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.asset = asset
        _navigationPath = navigationPath
        self.onComplete = onComplete
    }

    var body: some View {
        RecipientScene(
            model: RecipientViewModel(
                wallet: wallet,
                keystore: keystore,
                asset: asset,
                onRecipientDataAction: {
                    navigationPath.append($0)
                },
                onTransferAction: {
                    navigationPath.append($0)
                }
            )
        )
        .navigationDestination(for: RecipientData.self) { data in
            AmountNavigationView(
                input: AmountInput(type: .transfer(recipient: data), asset: data.asset),
                wallet: wallet,
                navigationPath: $navigationPath
            )
        }
        .navigationDestination(for: TransferData.self) { data in
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: wallet,
                    keystore: keystore,
                    data: data,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: data.recipientData.asset.chain),
                    walletsService: walletsService,
                    onComplete: { _ in
                        self.onComplete?()
                    }
                )
            )
        }
    }
}
