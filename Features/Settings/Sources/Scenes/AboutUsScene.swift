// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import PrimitivesComponents

public struct AboutUsScene: View {
    private let model: AboutUsViewModel

    public init(model: AboutUsViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            Section {
                SafariNavigationLink(url: model.termsOfServiceURL) {
                    ListItemView(title: model.termsOfServiceTitle)
                }
                SafariNavigationLink(url: model.privacyPolicyURL) {
                    ListItemView(title: model.privacyPolicyTitle)
                }
                SafariNavigationLink(url: model.websiteURL) {
                    ListItemView(title: model.websiteTitle)
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
