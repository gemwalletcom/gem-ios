// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletConnector
import Localization

struct ConnectionProposalViewModel {
    private let connectionsService: ConnectionsService
    private let confirmTransferDelegate: ConfirmTransferDelegate
    private let pairingProposal: WCPairingProposal

    var walletSelectorModel: SellectWalletViewModel

    init(
        connectionsService: ConnectionsService,
        confirmTransferDelegate: @escaping ConfirmTransferDelegate,
        pairingProposal: WCPairingProposal,
        wallets: [Wallet]
    ) {
        self.connectionsService = connectionsService
        self.confirmTransferDelegate = confirmTransferDelegate
        self.pairingProposal = pairingProposal
        self.walletSelectorModel = SellectWalletViewModel(
            wallets: wallets,
            selectedWallet: pairingProposal.proposal.wallet
        )
    }
    
    var title: String { Localized.WalletConnect.Connect.title }
    var buttonTitle: String { Localized.Transfer.confirm }
    var walletTitle: String { Localized.Common.wallet }
    var appTitle: String { Localized.WalletConnect.app }
    var websiteTitle: String { Localized.WalletConnect.website }

    var walletName: String {
        walletSelectorModel.walletModel.name
    }

    var appText: String {
        payload.metadata.name
    }
    
    var websiteText: String? {
        guard let url = URL(string: payload.metadata.url), let host = url.host(percentEncoded: true) else {
            return .none
        }
        return host
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
        let selectedWalletId = walletSelectorModel.walletModel.wallet.walletId
        if payload.wallet.walletId != selectedWalletId {
            try connectionsService.updateConnection(id: pairingProposal.id, wallet: selectedWalletId)
        }
        confirmTransferDelegate(.success(selectedWalletId.id))
    }
}
