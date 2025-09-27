// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
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
                        imageStyle: .asset(assetImage: AssetImage.image(Images.Logo.logo))
                    )
                }
            }
            
            if model.items(for: searchQuery).isEmpty {
                StateEmptyView(title: Localized.Common.noResultsFound)
            } else {
                Section {
                    ForEach(model.items(for: searchQuery)) { chain in
                        NavigationLink(value: ImportWalletType.chain(chain)) {
                            ListItemView(
                                title: Asset(chain).name,
                                imageStyle: .asset(assetImage: AssetImage.resourceImage(image: chain.rawValue))
                            )
                        }
                    }
                }
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
