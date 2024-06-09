// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Settings
import Components
import GemstonePrimitives

struct AboutUsScene: View {

    var body: some View {
        List {
            Section {
                NavigationCustomLink(with: ListItemView(title: Localized.Settings.termsOfServices)) {
                    UIApplication.shared.open(PublicConstants.url(.termsOfService))
                }
                NavigationCustomLink(with: ListItemView(title: Localized.Settings.privacyPolicy)) {
                    UIApplication.shared.open(PublicConstants.url(.privacyPolicy))
                }
                NavigationCustomLink(with: ListItemView(title: Localized.Settings.website)) {
                    UIApplication.shared.open(PublicConstants.url(.website))
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Localized.Settings.aboutus)
    }
}

struct AboutUsScene_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsScene()
    }
}

