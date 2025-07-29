// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import ChainService
import Localization
import Transfer
import SwapService
import ExplorerService
import Signer

struct ConfirmTransferNavigationStack: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.chainServiceFactory) private var chainServiceFactory
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.scanService) private var scanService
    @Environment(\.swapService) private var swapService
    @Environment(\.balanceService) private var balanceService
    @Environment(\.priceService) private var priceService
    @Environment(\.transactionService) private var transactionService

    private let wallet: Wallet
    private let transferData: TransferData
    private let onComplete: VoidAction

    public init(
        wallet: Wallet,
        transferData: TransferData,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.transferData = transferData
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationStack {
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: wallet,
                    data: transferData,
                    confirmService: ConfirmServiceFactory.create(
                        keystore: keystore,
                        nodeService: nodeService,
                        walletsService: walletsService,
                        scanService: scanService,
                        swapService: swapService,
                        balanceService: balanceService,
                        priceService: priceService,
                        transactionService: transactionService,
                        chain: transferData.chain
                    ),
                    onComplete: onComplete
                )
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        onComplete?()
                    }
                    .bold()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(true)
        }
    }
}
