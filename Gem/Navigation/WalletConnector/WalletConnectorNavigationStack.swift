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
    @Environment(\.keystore) private var keystore
    @Environment(\.chainServiceFactory) private var chainServiceFactory
    @Environment(\.walletsService) private var walletsService
    @Environment(\.connectionsService) private var connectionsService
    @Environment(\.scanService) private var scanService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.balanceService) private var balanceService
    @Environment(\.priceService) private var priceService
    @Environment(\.transactionService) private var transactionService

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
                            data: data.payload.tranferData,
                            confirmService: ConfirmServiceFactory.create(
                                keystore: keystore,
                                nodeService: nodeService,
                                walletsService: walletsService,
                                scanService: scanService,
                                balanceService: balanceService,
                                priceService: priceService,
                                transactionService: transactionService,
                                chain: data.payload.tranferData.chain
                            ),
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
