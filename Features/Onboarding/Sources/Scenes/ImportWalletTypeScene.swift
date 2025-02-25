import SwiftUI
import Keystore
import Components
import Primitives
import Style
import Localization

struct ImportWalletTypeScene: View {

    let model: ImportWalletTypeViewModel
    @State private var searchQuery = ""

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
                        image: Images.Logo.logo,
                        imageSize: .image.medium,
                        cornerRadius: .image.medium/2
                    )
                }
                .accessibilityIdentifier("multicoin")
            }
            if model.items(for: searchQuery).isEmpty {
                StateEmptyView(title: Localized.Common.noResultsFound)
            } else {
                Section {
                    ForEach(model.items(for: searchQuery)) { chain in
                        NavigationLink(value: ImportWalletType.chain(chain)) {
                            ListItemView(
                                title: Asset(chain).name,
                                image: Images.name(chain.rawValue),
                                imageSize: .image.medium,
                                cornerRadius: .image.medium/2
                            )
                        }
                    }
                }
            }
        }
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
