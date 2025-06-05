// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import ChainService
import Localization
import Transfer

struct ConfirmTransferNavigationStack: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.chainServiceFactory) private var chainServiceFactory
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService

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
                    keystore: keystore,
                    chainService: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: transferData.chain),
                    scanService: .main,
                    walletsService: walletsService,
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
