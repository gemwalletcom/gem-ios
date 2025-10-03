// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Localization
import Primitives
import PrimitivesComponents

public struct DeveloperScene: View {
    @State private var model: DeveloperViewModel

    public init(model: DeveloperViewModel) {
        _model = State(initialValue: model)
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
                    with: ListItemView(title: "Clear Transactions Timestamp"),
                    action: model.clearTransactionsTimestamp
                )
                NavigationCustomLink(
                    with: ListItemView(title: "Clear Wallet Preferences"),
                    action: model.clearWalletPreferences
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
                NavigationCustomLink(
                    with: ListItemView(title: "Activate All Cancelled Banners"),
                    action: model.activateAllCancelledBanners
                )
                NavigationCustomLink(
                    with: ListItemView(title: "Clear Perpetuals"),
                    action: model.clearPerpetuals
                )
                NavigationCustomLink(
                    with: ListItemView(title: "Clear Prices"),
                    action: model.clearPrices
                )
                #if DEBUG
                NavigationCustomLink(
                    with: ListItemView(title: "Add Transactions"),
                    action: model.addTransactions
                )
                #endif
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
        .toast(message: $model.isPresentingToastMessage)
    }
}
