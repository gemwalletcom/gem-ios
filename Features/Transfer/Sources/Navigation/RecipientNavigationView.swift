// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import ChainService
import QRScanner

public struct RecipientNavigationView: View {
    @State private var model: RecipientSceneViewModel
    private let confirmService: ConfirmService
    private let onComplete: VoidAction

    public init(
        confirmService: ConfirmService,
        model: RecipientSceneViewModel,
        onComplete: VoidAction
    ) {
        self.confirmService = confirmService
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
                    onTransferAction: model.onTransferAction
                )
            )
        }
        .navigationDestination(for: TransferData.self) { data in
            ConfirmTransferScene(
                model: ConfirmTransferSceneViewModel(
                    wallet: model.wallet,
                    data: data,
                    confirmService: confirmService,
                    onComplete: onComplete
                )
            )
        }
    }
}
