import SwiftUI
import Keystore
import Components
import Primitives
import Style

struct ImportWalletTypeScene: View {
    
    let model: ImportWalletTypeViewModel
    @State private var searchText = ""
    
    init(
        model: ImportWalletTypeViewModel
    ) {
        self.model = model
    }
    
    var body: some View {
        List {
            Section {
                NavigationLink(value: ImportWalletType.multicoin) {
                    ListItemView(
                        title: Localized.Wallet.multicoin,
                        image: Image(.multicoin),
                        imageSize: Sizing.image.chain,
                        cornerRadius: Sizing.image.chain/2
                    )
                }
                .accessibilityIdentifier("multicoin")
            }
            Section {
                ForEach(model.items(for: searchText) ) { chain in
                    NavigationLink(value: ImportWalletType.chain(chain)) {
                        ListItemView(
                            title: Asset(chain).name,
                            image: Image(chain.rawValue),
                            imageSize: Sizing.image.chain,
                            cornerRadius: Sizing.image.chain/2
                        )
                    }
                }
            }
        }
        //TODO: Enable later, but to make sure it does not jump
        //.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationBarTitle(model.title)
    }
}

//struct ImportWalletTypeScene_Previews: PreviewProvider {
//    static var previews: some View {
//        ImportWalletTypeScene(model: ImportWalletTypeViewModel(keystore: .main))
//    }
//}
