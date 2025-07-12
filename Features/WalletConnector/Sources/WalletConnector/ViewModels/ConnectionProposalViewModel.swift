// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletConnectorService
import Localization
import PrimitivesComponents

public struct ConnectionProposalViewModel {
    private let connectionsService: ConnectionsService
    private let confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate
    private let pairingProposal: WCPairingProposal

    var walletSelectorModel: SelectWalletViewModel

    public init(
        connectionsService: ConnectionsService,
        confirmTransferDelegate: @escaping TransferDataCallback.ConfirmTransferDelegate,
        pairingProposal: WCPairingProposal
    ) {
        self.connectionsService = connectionsService
        self.confirmTransferDelegate = confirmTransferDelegate
        self.pairingProposal = pairingProposal
        self.walletSelectorModel = SelectWalletViewModel(
            wallets: pairingProposal.proposal.wallets,
            selectedWallet: pairingProposal.proposal.defaultWallet
        )
    }
    
    var title: String { Localized.WalletConnect.Connect.title }
    var buttonTitle: String { Localized.Transfer.confirm }
    var walletTitle: String { Localized.Common.wallet }
    var appTitle: String { Localized.WalletConnect.app }

    var walletName: String {
        walletSelectorModel.selectedItems.first?.name ?? .empty
    }

    var appName: String {
        payload.metadata.shortName
    }
    
    var websiteText: String? {
        guard let url = URL(string: payload.metadata.url), let host = url.host(percentEncoded: true) else {
            return .none
        }
        return host
    }
    
    var appText: String {
        AppDisplayFormatter.format(name: appName, host: websiteText)
    }
    
    var imageUrl: URL? {
        URL(string: payload.metadata.icon)
    }

    private var payload: WalletConnectionSessionProposal {
        pairingProposal.proposal
    }
}

// MARK: - Business Logic

extension ConnectionProposalViewModel {
    func accept() throws {
        guard let selectedWallet = walletSelectorModel.selectedItems.first else {
            return
        }
        confirmTransferDelegate(.success(selectedWallet.id))
    }
}
