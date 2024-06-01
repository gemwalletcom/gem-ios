// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct ConnectionProposalViewModel {

    private let confirmTransferDelegate: ConfirmTransferDelegate
    private let payload: WalletConnectionSessionProposal

    init(
        confirmTransferDelegate: @escaping ConfirmTransferDelegate,
        payload: WalletConnectionSessionProposal
    ) {
        self.confirmTransferDelegate = confirmTransferDelegate
        self.payload = payload
    }
    
    var title: String {
        return Localized.WalletConnect.Connect.title
    }
    
    var walletText: String {
        return payload.wallet.name
    }
    
    var appText: String {
        return payload.metadata.name
    }
    
    var websiteText: String? {
        guard let url = URL(string: payload.metadata.url), let host = url.host(percentEncoded: true) else {
            return .none
        }
        return host
    }
    
    var imageUrl: URL? {
        return URL(string: payload.metadata.icon)
    }
    
    var buttonTitle: String { Localized.Transfer.confirm }
    
    func accept() throws {
        confirmTransferDelegate(.success(""))
    }
}
