import SwiftUI
import Components
import Primitives
import Style
import Localization

struct ImportWalletTypeScene: View {

    let model: ImportWalletTypeViewModel
    @State private var searchQuery = ""

    init(model: ImportWalletTypeViewModel) {
        self.model = model
    }

    var body: some View {
        List {
            Section {
                let view = ListItemView(
                    title: Localized.Wallet.multicoin,
                    imageStyle: .asset(assetImage: AssetImage.image(Images.Logo.logo))
                )
                NavigationCustomLink(with: view) {
                    model.onNext(type: .multicoin)
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
                            model.onNext(type: .chain(chain))
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
