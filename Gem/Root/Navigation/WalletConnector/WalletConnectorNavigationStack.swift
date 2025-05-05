// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import WalletConnector

struct WalletConnectorNavigationStack: View {
    @Environment(\.keystore) var keystore
    @Environment(\.chainServiceFactory) var chainServiceFactory
    @Environment(\.walletsService) var walletsService
    @Environment(\.connectionsService) var connectionsService

    private let type: WalletConnectorSheetType
    private let presenter: WalletConnectorPresenter

    init(
        type: WalletConnectorSheetType,
        presenter: WalletConnectorPresenter
    ) {
        self.type = type
        self.presenter = presenter
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
                                .service(for: data.payload.tranferData.chain),
                            walletsService: walletsService,
                            confirmTransferDelegate: data.delegate,
                            onComplete: { presenter.complete(type: type) }
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
                            pairingProposal: data.payload
                        )
                    )
                }
            }
            .interactiveDismissDisabled(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        presenter.cancelSheet(type: type)
                    }
                    .bold()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
