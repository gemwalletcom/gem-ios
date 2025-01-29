// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Keystore
import ChainService
import Localization

struct ConfirmTransferNavigationStack: View {
    
    @Environment(\.keystore) var keystore
    @Environment(\.chainServiceFactory) var chainServiceFactory
    @Environment(\.walletsService) var walletsService
    @Environment(\.nodeService) var nodeService
    
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
                    keystore: keystore,
                    data: transferData,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: transferData.chain),
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
