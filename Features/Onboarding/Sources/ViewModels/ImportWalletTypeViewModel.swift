import Foundation
import Primitives
import WalletService
import SwiftUI
import Localization
import PrimitivesComponents

public struct ImportWalletTypeViewModel {
    let walletService: WalletService

    public init(walletService: WalletService) {
        self.walletService = walletService
    }
    
    var title: String {
        Localized.Wallet.Import.title
    }

    func items(for searchText: String) -> [Chain] {
        filterChains(for: searchText)
    }
    
    func acceptTerms() {
        walletService.acceptTerms()
    }
}

// MARK: - Equatable

extension ImportWalletTypeViewModel: Equatable {
    public static func == (lhs: ImportWalletTypeViewModel, rhs: ImportWalletTypeViewModel) -> Bool {
        return lhs.chains == rhs.chains
    }
}

// MARK: - Hashable

extension ImportWalletTypeViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(chains)
    }
}

// MARK: - ChainFilterable

extension ImportWalletTypeViewModel: ChainFilterable {
    public var chains: [Chain] {
        AssetConfiguration.allChains.sortByRank()
    }
}
