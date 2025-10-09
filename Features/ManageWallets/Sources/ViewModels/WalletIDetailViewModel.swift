import SwiftUI
import WalletService
import Primitives
import Components
import Style
import Localization
import PrimitivesComponents
import ExplorerService
import Store
import Onboarding

@Observable
@MainActor
public final class WalletDetailViewModel {

    private let navigationPath: Binding<NavigationPath>
    let wallet: Wallet
    let walletService: WalletService
    private let explorerService: any ExplorerLinkFetchable

    var nameInput: String
    var isPresentingAlertMessage: AlertMessage?
    var isPresentingDeleteConfirmation: Bool?
    var isPresentingExportWallet: ExportWalletType?

    public init(
        navigationPath: Binding<NavigationPath>,
        wallet: Wallet,
        walletService: WalletService,
        explorerService: any ExplorerLinkFetchable = ExplorerService.standard
    ) {
        self.navigationPath = navigationPath
        self.wallet = wallet
        self.walletService = walletService
        self.explorerService = explorerService
        self.nameInput = wallet.name
        self.isPresentingAlertMessage = nil
        self.isPresentingDeleteConfirmation = nil
        self.isPresentingExportWallet = nil
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

    func addressLink(account: SimpleAccount) -> BlockExplorerLink {
        explorerService.addressUrl(chain: account.chain, address: account.address)
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
        try walletService.rename(walletId: wallet.walletId, newName: name)
    }
    
    func getMnemonicWords() throws -> [String] {
        try walletService.getMnemonic(wallet: wallet)
    }
    
    func getPrivateKey() throws -> String {
        let chain = wallet.accounts[0].chain
        return try walletService.getPrivateKey(
            wallet: wallet,
            chain: chain,
            encoding: chain.defaultKeyEncodingType
        )
    }

    func delete() throws {
        try walletService.delete(wallet)
    }

    func onSelectImage() {
        navigationPath.wrappedValue.append(Scenes.WalletSelectImage(wallet: wallet))
    }
}

// MARK: - Actions

extension WalletDetailViewModel {
    func onChangeWalletName() {
        do {
            try rename(name: nameInput)
        } catch {
            isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
        }
    }

    func onShowSecretPhrase() {
        do {
            isPresentingExportWallet = .words(try getMnemonicWords())
        } catch {
            isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
        }
    }

    func onShowPrivateKey() {
        do {
            isPresentingExportWallet = .privateKey(try getPrivateKey())
        } catch {
            isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
        }
    }

    func onSelectDelete() {
        isPresentingDeleteConfirmation = true
    }

    func onDelete() -> Bool {
        do {
            try delete()
            return true
        } catch {
            isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
            return false
        }
    }
}
