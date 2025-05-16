// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Transfer
import ChainService
import PrimitivesComponents
import WalletsService
import QRScanner

struct RecipientNavigationView: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.walletService) private var walletService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService

    @State private var model: RecipientSceneViewModel
    @Binding private var navigationPath: NavigationPath

    private let onComplete: VoidAction

    init(
        model: RecipientSceneViewModel,
        navigationPath: Binding<NavigationPath>,
        onComplete: VoidAction
    ) {
        _navigationPath = navigationPath
        _model = State(initialValue: model)
        self.onComplete = onComplete
    }

    var body: some View {
        RecipientScene(
            model: model
        )
        .sheet(item: $model.isPresentingScanner) { value in
            ScanQRCodeNavigationStack() {
                model.onHandleScan($0, for: value)
            }
        }
        .navigationDestination(for: RecipientData.self) { data in
            AmountNavigationView(
                input: AmountInput(type: .transfer(recipient: data), asset: model.asset),
                wallet: model.wallet,
                navigationPath: $navigationPath
            )
        }
        .navigationDestination(for: TransferData.self) { data in
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: model.wallet,
                    keystore: keystore,
                    data: data,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: data.chain),
                    walletsService: walletsService,
                    onComplete: onComplete
                )
            )
        }
    }
}
