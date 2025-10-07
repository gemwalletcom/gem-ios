// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import PrimitivesComponents
import Localization
import Style

public struct AboutUsScene: View {
    @State private var model: AboutUsViewModel

    public init(model: AboutUsViewModel) {
        _model = State(initialValue: model)
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

                if let version = model.releaseVersion {
                    NavigationCustomLink(
                        with: ListItemView(
                            title: Localized.UpdateApp.title,
                            subtitle: version,
                            imageStyle: .settings(assetImage: model.releaseImage)
                        ),
                        action: model.onUpdate
                    )
                }
            }
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .taskOnce { Task { await model.fetch() }}
    }
}
