import Foundation
import Primitives
import WalletService
import SwiftUI
import Localization
import PrimitivesComponents

@MainActor
protocol ImportWalletTypeViewModelNavigation {
    func importWalletOnNext(type: ImportWalletType)
}

struct ImportWalletTypeViewModel {
    private let walletService: WalletService
    private let navigation: ImportWalletTypeViewModelNavigation

    init(
        walletService: WalletService,
        navigation: ImportWalletTypeViewModelNavigation
    ) {
        self.walletService = walletService
        self.navigation = navigation
    }
    
    var title: String {
        Localized.Wallet.Import.title
    }

    func items(for searchText: String) -> [Chain] {
        filterChains(for: searchText)
    }
}

// MARK: - Navigation

@MainActor
extension ImportWalletTypeViewModel {
    func onNext(type: ImportWalletType) {
        navigation.importWalletOnNext(type: type)
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
