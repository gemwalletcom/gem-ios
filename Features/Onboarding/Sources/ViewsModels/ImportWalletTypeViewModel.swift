import Foundation
import Primitives
import ManageWalletService
import SwiftUI
import Localization
import PrimitivesComponents

public struct ImportWalletTypeViewModel {
    let manageWalletService: ManageWalletService

    public init(manageWalletService: ManageWalletService) {
        self.manageWalletService = manageWalletService
    }
    
    var title: String {
        Localized.Wallet.Import.title
    }

    func items(for searchText: String) -> [Chain] {
        filterChains(for: searchText)
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
