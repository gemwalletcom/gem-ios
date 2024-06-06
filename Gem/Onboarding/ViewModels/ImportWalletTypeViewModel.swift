import Foundation
import Primitives
import Settings
import Keystore
import SwiftUI

struct ImportWalletTypeViewModel {
    
    let keystore: any Keystore
    
    init(keystore: any Keystore) {
        self.keystore = keystore
    }
    
    var title: String {
        return Localized.Wallet.Import.title
    }

    var chains: [Chain] {
        return AssetConfiguration.allChains
    }
    
    func items(for searchText: String) -> [Chain] {
        guard !searchText.isEmpty else {
            return chains
        }
        return chains.filter {
            $0.asset.name.localizedCaseInsensitiveContains(searchText) ||
            $0.asset.symbol.localizedCaseInsensitiveContains(searchText) ||
            $0.rawValue.localizedCaseInsensitiveContains(searchText)
        }
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
