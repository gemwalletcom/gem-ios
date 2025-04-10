// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import PrimitivesComponents

public struct AboutUsScene: View {
    @Environment(\.openURL) private var openURL

    private let model: AboutUsViewModel

    public init(model: AboutUsViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            Section {
                NavigationCustomLink(with: ListItemView(title: model.termsOfServiceTitle)) {
                    openURL(model.termsOfServiceURL)
                }
                NavigationCustomLink(with: ListItemView(title: model.privacyPolicyTitle)) {
                    openURL(model.privacyPolicyURL)
                }
                NavigationCustomLink(with: ListItemView(title: model.websiteTitle)) {
                    openURL(model.websiteURL)
                }
            }
            Section {
                ListItemView(
                    title: model.versionTextTitle,
                    subtitle: model.versionTextValue,
                    imageStyle: .settings(assetImage: model.versionTextImage)
                )
                .contextMenu(model.contextMenuItems)
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
    }
}
