import SwiftUI
import ManageWalletService
import WalletAvatar
import Primitives
import Keystore
import Components
import Style
import Localization
import PrimitivesComponents
import ExplorerService
import Store

public class WalletDetailViewModel {

    @Binding var navigationPath: NavigationPath
    let wallet: Wallet
    let walletService: ManageWalletService
    let explorerService: any ExplorerLinkFetchable

    public init(
        navigationPath: Binding<NavigationPath>,
        wallet: Wallet,
        walletService: ManageWalletService,
        explorerService: any ExplorerLinkFetchable = ExplorerService.standard
    ) {
        _navigationPath = navigationPath
        self.wallet = wallet
        self.walletService = walletService
        self.explorerService = explorerService
    }

    var name: String {
        wallet.name
    }
    
    var title: String {
        return Localized.Common.wallet
    }
    
    var address: WalletDetailAddress? {
        switch wallet.type {
        case .multicoin:
            return .none
        case .single, .view, .privateKey:
            guard let account = wallet.accounts.first else { return .none }
            return WalletDetailAddress.account(
                SimpleAccount(
                    name: .none,
                    chain: account.chain,
                    address: account.address,
                    assetImage: .none
                )
            )
        }
    }
    
    var walletRequest: WalletRequest {
        WalletRequest(walletId: wallet.id)
    }
    
    func avatarAssetImage(for wallet: Wallet) -> AssetImage {
        let avatar = WalletViewModel(wallet: wallet).avatarImage
        return AssetImage(
            type: avatar.type,
            imageURL: avatar.imageURL,
            placeholder: avatar.placeholder,
            chainPlaceholder: Images.Wallets.editFilled
        )
    }
}

// MARK: - Business Logic

extension WalletDetailViewModel {
    func rename(name: String) throws {
        try walletService.renameWallet(wallet: wallet, newName: name)
    }
    
    func getMnemonicWords() throws -> [String] {
        try walletService.getMnemonic(wallet: wallet)
    }
    
    func getPrivateKey(for chain: Chain) throws -> String {
        let encoding = getEncodingType(for: chain)
        return try walletService.getPrivateKey(wallet: wallet, chain: chain, encoding: encoding)
    }
    
    func getEncodingType(for chain: Chain) -> EncodingType {
        return chain.defaultKeyEncodingType
    }

    func delete() throws {
        try walletService.delete(wallet)
    }

    func onSelectImage() {
        navigationPath.append(Scenes.WalletSelectImage(wallet: wallet))
    }
}
