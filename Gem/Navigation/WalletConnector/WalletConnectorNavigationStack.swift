// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import WalletConnector
import Transfer
import TransactionService
import ExplorerService
import Signer

struct WalletConnectorNavigationStack: View {
    @Environment(\.viewModelFactory) private var viewModelFactory
    @Environment(\.keystore) private var keystore
    @Environment(\.connectionsService) private var connectionsService

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
                        model: viewModelFactory.confirmTransferScene(
                            wallet: data.payload.wallet,
                            presentation: .confirm(data.payload.tranferData),
                            confirmTransferDelegate: data.delegate,
                            onComplete: { presenter.complete(type: type) }
                        )
                    )
                case .signMessage(let data):
                    SignMessageScene(
                        model: viewModelFactory.signMessageScene(
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Localized.Common.cancel) {
                        presenter.cancelSheet(type: type)
                    }
                    .bold()
                }
            }
        }
    }
}
