// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import ChainService
import QRScanner

public struct RecipientNavigationView: View {
    @State private var model: RecipientSceneViewModel
    private let confirmService: ConfirmService

    public init(
        confirmService: ConfirmService,
        model: RecipientSceneViewModel
    ) {
        self.confirmService = confirmService
        _model = State(initialValue: model)
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
    }
}
