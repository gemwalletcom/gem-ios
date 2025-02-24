// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletConnectorService
import Localization

public struct ConnectionProposalViewModel {
    private let connectionsService: ConnectionsService
    private let confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate
    private let pairingProposal: WCPairingProposal

    var walletSelectorModel: SellectWalletViewModel

    public init(
        connectionsService: ConnectionsService,
        confirmTransferDelegate: @escaping TransferDataCallback.ConfirmTransferDelegate,
        pairingProposal: WCPairingProposal
    ) {
        self.connectionsService = connectionsService
        self.confirmTransferDelegate = confirmTransferDelegate
        self.pairingProposal = pairingProposal
        self.walletSelectorModel = SellectWalletViewModel(
            wallets: pairingProposal.proposal.wallets,
            selectedWallet: pairingProposal.proposal.defaultWallet
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
        confirmTransferDelegate(.success(selectedWalletId.id))
    }
}
