import Foundation
import Primitives
import Settings
import Keystore
import SwiftUI

struct ImportWalletTypeViewModel: ChainFilterable {

    let keystore: any Keystore
    
    init(keystore: any Keystore) {
        self.keystore = keystore
    }
    
    var title: String {
        return Localized.Wallet.Import.title
    }

    func items(for searchText: String) -> [Chain] {
        filterChains(for: searchText)
    }
}

extension ImportWalletTypeViewModel: Equatable {
    static func == (lhs: ImportWalletTypeViewModel, rhs: ImportWalletTypeViewModel) -> Bool {
        return lhs.chains == rhs.chains
    }
}

extension ImportWalletTypeViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(chains)
    }
}
