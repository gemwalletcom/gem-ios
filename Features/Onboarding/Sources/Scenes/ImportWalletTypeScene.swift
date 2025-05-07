import SwiftUI
import Components
import Primitives
import Style
import Localization

struct ImportWalletTypeScene: View {

    let model: ImportWalletTypeViewModel
    let router: Routing
    @State private var searchQuery = ""

    init(
        model: ImportWalletTypeViewModel,
        router: Routing
    ) {
        self.model = model
        self.router = router
    }

    var body: some View {
        List {
            Section {
                let view = ListItemView(
                    title: Localized.Wallet.multicoin,
                    imageStyle: .asset(assetImage: AssetImage.image(Images.Logo.logo))
                )
                NavigationCustomLink(with: view) {
                    router.push(to: ImportWalletDestination.importWallet(.multicoin))
                }
            }
            .listRowInsets(.assetListRowInsets)
            
            if model.items(for: searchQuery).isEmpty {
                StateEmptyView(title: Localized.Common.noResultsFound)
            } else {
                Section {
                    ForEach(model.items(for: searchQuery)) { chain in
                        let view = ListItemView(
                            title: Asset(chain).name,
                            imageStyle: .asset(assetImage: AssetImage.resourceImage(image: chain.rawValue))
                        )
                        NavigationCustomLink(with: view) {
                            router.push(to: ImportWalletDestination.importWallet(.chain(chain)))
                        }
                    }
                }
                .listRowInsets(.assetListRowInsets)
            }
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .navigationBarTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchQuery,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .autocorrectionDisabled(true)
        .scrollDismissesKeyboard(.interactively)
    }
}
