// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct ConnectionProposalViewModel {
    private let confirmTransferDelegate: ConfirmTransferDelegate
    private let payload: WalletConnectionSessionProposal

    var walletSelectorModel: WalletSelectorViewModel

    init(
        confirmTransferDelegate: @escaping ConfirmTransferDelegate,
        payload: WalletConnectionSessionProposal,
        wallets: [Wallet]
    ) {
        self.confirmTransferDelegate = confirmTransferDelegate
        self.payload = payload
        self.walletSelectorModel = WalletSelectorViewModel(
            wallets: wallets,
            selectedWallet: payload.wallet
        )
    }
    
    var title: String { Localized.WalletConnect.Connect.title }
    var buttonTitle: String { Localized.Transfer.confirm }

    var selectedWalletName: String {
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
}

// MARK: - Business Logic

extension ConnectionProposalViewModel {
    func accept() throws {
        confirmTransferDelegate(.success(""))
    }
}
