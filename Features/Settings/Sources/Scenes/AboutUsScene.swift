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
                SafariLink(url: model.termsOfServiceURL) {
                    ListItemView(title: model.termsOfServiceTitle)
                }
                SafariLink(url: model.privacyPolicyURL) {
                    ListItemView(title: model.privacyPolicyTitle)
                }
                SafariLink(url: model.websiteURL) {
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
