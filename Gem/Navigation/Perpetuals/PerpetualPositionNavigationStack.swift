// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import PrimitivesComponents
import Components
import Transfer
import ChainService
import Keystore
import SwapService
import Swap
import StakeService

struct PerpetualPositionNavigationStack: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService
    @Environment(\.scanService) private var scanService
    @Environment(\.swapService) private var swapService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.stakeService) private var stakeService
    
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
                model: AmountSceneViewModel(
                    input: AmountInput(
                        type: .perpetual(
                            recipient: perpetualRecipientData.recipient,
                            perpetual: perpetualRecipientData.data
                        ),
                        asset: perpetualRecipientData.data.asset
                    ),
                    wallet: wallet,
                    walletsService: walletsService,
                    stakeService: stakeService,
                    onTransferAction: { transferData in
                        navigationPath.append(transferData)
                    }
                )
            )
            .toolbar {
                ToolbarDismissItem(
                    title: .cancel,
                    placement: .navigationBarLeading
                )
            }
            .navigationDestination(for: TransferData.self) { data in
                ConfirmTransferScene(
                    model: ConfirmTransferViewModel(
                        wallet: wallet,
                        data: data,
                        keystore: keystore,
                        chainService: ChainServiceFactory(nodeProvider: nodeService).service(for: data.chain),
                        scanService: scanService,
                        swapService: swapService,
                        walletsService: walletsService,
                        swapDataProvider: SwapQuoteDataProvider(
                            keystore: keystore,
                            swapService: swapService
                        ),
                        onComplete: {
                            onComplete?()
                        }
                    )
                )
            }
        }
    }
}
