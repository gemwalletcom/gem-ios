import Foundation
import SwiftUI
import Components

struct WalletInfoScene: View {
    
    let model: WalletInfoViewModel
    
    @State private var name: String
    
    // next
    @State var words: [String]? = nil
    @State private var isPresentingErrorMessage: String?

    init(model: WalletInfoViewModel) {
        self.model = model
        self.name = model.name
    }
    
    var body: some View {
        List {
            Section {
                FloatTextField(Localized.Wallet.name, text: $name)
            }
            switch model.wallet.type {
            case .multicoin, .single:
                Section {
                    NavigationCustomLink(
                        with: ListItemView(title: Localized.Common.show(Localized.Common.secretPhrase))
                    ) {
                        Task {
                            do {
                                self.words = try model.keystore.getMnemonic(wallet: model.wallet)
                            } catch {
                                isPresentingErrorMessage = error.localizedDescription
                            }
                        }
                    }
                } header: {
                    Text(Localized.Common.secretPhrase)
                }
            case .view:
                EmptyView()
            }
            Section {
                switch model.address {
                case .account(let account):
                    AddressListItem(title: Localized.Common.address, style: .short, account: account)
                case .none:
                    EmptyView()
                }
            }
            
        }
        .navigationTitle(model.title)
        .onChange(of: name) {
            try? model.rename(name: name)
        }
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(Localized.Errors.transfer("")), message: Text($0))
        }
        .navigationDestination(for: $words) { words in
            ShowSecretPhraseScene(model: ShowSecretPhraseViewModel(words: words))
        }
    }
}

//struct WalletInfoScene_Previews: PreviewProvider {
//    static var previews: some View {
//        WalletInfoScene(
//            model: WalletInfoViewModel(wallet: .main, keystore: LocalKeystore.main)
//        )
//    }
//}
