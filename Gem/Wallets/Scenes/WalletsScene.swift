import SwiftUI
import Components
import Keystore
import Primitives
import GRDBQuery
import Store
import Style

struct WalletsScene: View {
    
    var model: WalletsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.db) private var DB
    @State private var isPresentingErrorMessage: String?
    @State private var showingDeleteAlert = false
    
    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false
    
    @Query<WalletsRequest>
    var wallets: [Wallet]
    
    @State var walletEdit: Wallet? = .none
    
    init(
        model: WalletsViewModel
    ) {
        self.model = model
        _wallets = Query(WalletsRequest(), in: \.db.dbQueue)
    }
    
    var body: some View {
        List {
            Section {
                Button {
                    isPresentingCreateWalletSheet.toggle()
                } label: {
                    HStack {
                        Image(.createWallet)
                        Text(Localized.Wallet.createNewWallet)
                    }
                }
                Button {
                    isPresentingImportWalletSheet.toggle()
                } label: {
                    HStack {
                        Image(.importWallet)
                        Text(Localized.Wallet.importExistingWallet)
                    }
                }
            }
            Section {
                ForEach(wallets.map { WalletViewModel(wallet: $0) }) { wallet in
                    // https://www.jessesquires.com/blog/2023/07/18/navigation-link-accessory-view-swiftui
                    // Hack to hide chevron
                    ZStack {
                        NavigationCustomLink(
                            with: EmptyView(),
                            action: { selectWallet(wallet.wallet) }
                        )
                        .opacity(0)

                        HStack {
                            AssetImageView(assetImage: wallet.assetImage, size: Sizing.image.chain)
                            ListItemView(title: wallet.name, titleExtra: wallet.subType)
                            
                            Spacer()
                            
                            if model.currentWallet == wallet.wallet {
                                Image(.walletSelected)
                            }
                            
                            Button(role: .none) {
                                edit(wallet: wallet.wallet)
                            } label: {
                                Image(.editIcon)
                                    .padding(.vertical, 8)
                                    .padding(.leading, Spacing.small)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .contextMenu {
                        ContextMenuItem(
                            title: Localized.Common.wallet,
                            image: SystemImage.settings
                        ) {
                            edit(wallet: wallet.wallet)
                        }
                        ContextMenuDelete {
                            deleteWallet(wallet.wallet)
                        }
                    }
                    .swipeActions {
                        Button(role: .none) { edit(wallet: wallet.wallet) } label: {
                            Label("", systemImage: SystemImage.settings)
                        }
                        .tint(Colors.gray)
                        
                        Button(Localized.Common.delete, role: .destructive) {
                            deleteWallet(wallet.wallet)
                        }
                        .tint(Colors.red)
                    }
                }
            }
        }
        .navigationDestination(for: $walletEdit) { wallet in
            WalletDetailScene(
                model: WalletDetailViewModel(wallet: wallet, keystore: model.keystore)
            )
        }
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(""), message: Text($0))
        }
        .sheet(isPresented: $isPresentingCreateWalletSheet) {
            CreateWalletNavigationStack(isPresenting: $isPresentingCreateWalletSheet)
        }
        .sheet(isPresented: $isPresentingImportWalletSheet) {
            ImportWalletNavigationStack(isPresenting: $isPresentingImportWalletSheet)
        }
        .navigationBarTitle(model.title)
    }
    
    func selectWallet(_ wallet: Wallet) {
        model.setCurrentWallet(wallet)
        dismiss()
        dismiss()
    }
    
    func deleteWallet(_ wallet: Wallet) {
        Task {
            do {
                let _ = try model.deleteWallet(wallet)
            } catch {
                isPresentingErrorMessage = error.localizedDescription
            }
        }
    }
    
    func edit(wallet: Wallet) {
        self.walletEdit = wallet
    }
}

//struct WalletsScene_Previews: PreviewProvider {
//    static var previews: some View {
//        WalletsScene(model: WalletsViewModel(keystore: .main))
//    }
//}
