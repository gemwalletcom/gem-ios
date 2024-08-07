import Foundation
import SwiftUI
import Components

struct DeveloperScene: View {
    
    let model: DeveloperViewModel
    
    var body: some View {
        List {
            Section("Device") {
                ListItemView(title: "Device ID", subtitle: model.deviceId)
                    .contextMenu {
                        ContextMenuCopy(title: Localized.Common.copy, value: model.deviceId)
                    }
                ListItemView(title: "Device Token", subtitle: model.deviceToken)
                    .contextMenu {
                        ContextMenuCopy(title: Localized.Common.copy, value: model.deviceToken)
                    }
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
