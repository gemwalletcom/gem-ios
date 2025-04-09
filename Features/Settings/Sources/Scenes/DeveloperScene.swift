// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Localization
import Primitives
import PrimitivesComponents

public struct DeveloperScene: View {
    private let model: DeveloperViewModel

    public init(model: DeveloperViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            Section("Device") {
                ListItemView(title: "Device ID", subtitle: model.deviceId)
                    .contextMenu(.copy(value: model.deviceId))
                ListItemView(title: "Device Token", subtitle: model.deviceToken)
                    .contextMenu(.copy(value: model.deviceToken))
            }
            Section("Networking") {
                NavigationCustomLink(
                    with: ListItemView(title: "Clear URLCache"),
                    action: model.clearCache
                )
            }
            
            Section("Database") {
                NavigationCustomLink(
                    with: ListItemView(title: "Clear Transactions"),
                    action: model.clearTransactions
                )
                NavigationCustomLink(
                    with: ListItemView(title: "Clear Pending Transactions"),
                    action: model.clearPendingTransactions
                )
                NavigationCustomLink(
                    with: ListItemView(title: "Clear Assets"),
                    action: model.clearAssets
                )
                NavigationCustomLink(
                    with: ListItemView(title: "Clear Delegations"),
                    action: model.clearDelegations
                )
                NavigationCustomLink(
                    with: ListItemView(title: "Clear Validators"),
                    action: model.clearValidators
                )
                NavigationCustomLink(
                    with: ListItemView(title: "Clear Banners"),
                    action: model.clearBanners
                )
            }
            
            Section("Deeplinks") {
                NavigationCustomLink(
                    with: ListItemView(title: "Open Asset (Bitcoin)"),
                    action: {
                        model.deeplink(deeplink: .asset(AssetId(chain: .bitcoin, tokenId: .none)))
                    }
                )
            }
            
            Section("Preferences") {
                NavigationCustomLink(
                    with: ListItemView(title: "Clear Swap Assets Version"),
                    action: model.clearAssetsVersion 
                )
            }
            
            Section {
                NavigationCustomLink(with: ListItemView(title: "Reset"), action: model.reset)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(model.title)
    }
}
