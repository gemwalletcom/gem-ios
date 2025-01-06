// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import WalletConnector

struct WalletConnectorNavigationStack: View {
    typealias OnConnectorAction = ((WalletConnectorSheetType) -> Void)

    @Environment(\.keystore) var keystore
    @Environment(\.chainServiceFactory) var chainServiceFactory
    @Environment(\.walletsService) var walletsService
    @Environment(\.connectionsService) var connectionsService

    private let type: WalletConnectorSheetType
    private let onComplete: OnConnectorAction?
    private let onCancel: OnConnectorAction?

    init(
        type: WalletConnectorSheetType,
        onComplete: OnConnectorAction?,
        onCancel: OnConnectorAction?
    ) {
        self.type = type
        self.onComplete = onComplete
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            Group {
                switch type {
                case .transferData(let data):
                    ConfirmTransferScene(
                        model: ConfirmTransferViewModel(
                            wallet: data.payload.wallet,
                            keystore: keystore,
                            data: data.payload.tranferData,
                            service: chainServiceFactory
                                .service(for: data.payload.tranferData.recipientData.asset.chain),
                            walletsService: walletsService,
                            confirmTransferDelegate: data.delegate,
                            onComplete: {
                                onComplete?(type)
                            }
                        )
                    )
                case .signMessage(let data):
                    SignMessageScene(
                        model: SignMessageSceneViewModel(
                            keystore: keystore,
                            payload: data.payload,
                            confirmTransferDelegate: data.delegate
                        )
                    )

                case .connectionProposal(let data):
                    ConnectionProposalScene(
                        model: ConnectionProposalViewModel(
                            connectionsService: connectionsService,
                            confirmTransferDelegate: data.delegate,
                            pairingProposal: data.payload,
                            wallets: keystore.wallets
                        )
                    )
                }
            }
            .interactiveDismissDisabled(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        onCancel?(type)
                    }
                    .bold()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
