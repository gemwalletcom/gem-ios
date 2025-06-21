// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import ChainService
import QRScanner

public struct RecipientNavigationView: View {
    @State private var model: RecipientSceneViewModel

    private let onComplete: VoidAction

    public init(
        model: RecipientSceneViewModel,
        onComplete: VoidAction
    ) {
        _model = State(initialValue: model)
        self.onComplete = onComplete
    }

    public var body: some View {
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
                model: AmountSceneViewModel(
                    input: AmountInput(type: .transfer(recipient: data), asset: model.asset),
                    wallet: model.wallet,
                    walletsService: model.walletsService,
                    stakeService: model.stakeService,
                    onTransferAction: model.onTransferAction
                )
            )
        }
        .navigationDestination(for: TransferData.self) { data in
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: model.wallet,
                    data: data,
                    keystore: model.keystore,
                    chainService: ChainServiceFactory(nodeProvider: model.nodeService)
                        .service(for: data.chain),
                    scanService: model.scanService,
                    walletsService: model.walletsService,
                    onComplete: onComplete
                )
            )
        }
    }
}
