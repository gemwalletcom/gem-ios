// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import PrimitivesComponents
import Components
import Transfer

struct PerpetualPositionNavigationStack: View {
    @Environment(\.viewModelFactory) private var viewModelFactory
    
    @State private var navigationPath = NavigationPath()
    
    let perpetualRecipientData: PerpetualRecipientData
    let wallet: Wallet
    let onComplete: VoidAction
    
    init(
        perpetualRecipientData: PerpetualRecipientData,
        wallet: Wallet,
        onComplete: VoidAction
    ) {
        self.perpetualRecipientData = perpetualRecipientData
        self.wallet = wallet
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            AmountNavigationView(
                model: viewModelFactory.amountScene(
                    input: AmountInput(
                        type: .perpetual(
                            recipient: perpetualRecipientData.recipient,
                            perpetual: perpetualRecipientData.data
                        ),
                        asset: .hypercoreUSDC()
                    ),
                    wallet: wallet,
                    onTransferAction: {
                        navigationPath.append($0)
                    }
                )
            )
            .toolbar {
                ToolbarDismissItem(
                    title: .cancel,
                    placement: .navigationBarLeading
                )
            }
            .navigationDestination(for: TransferData.self) {
                ConfirmTransferScene(
                    model: viewModelFactory.confirmTransferScene(
                        wallet: wallet,
                        data: $0,
                        onComplete: {
                            onComplete?()
                        }
                    )
                )
            }
        }
    }
}
