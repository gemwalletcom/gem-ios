// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

@Observable
final class NavigationStateManager: Sendable {
    @MainActor
    var wallet = NavigationPath()
    @MainActor
    var search = NavigationPath()
    @MainActor
    var collections = NavigationPath()
    @MainActor
    var activity = NavigationPath()
    @MainActor
    var settings = NavigationPath()
    @MainActor
    var markets = NavigationPath()

    @MainActor
    var selectedTab: TabItem = .wallet
    @MainActor
    var previousSelectedTab: TabItem = .wallet

    init() {}
}

// MARK: - Business Logic

@MainActor
extension NavigationStateManager {
    func select(tab: TabItem) {
        selectedTab = tab
        // back to root if selected same tab, if some routes already in stack
        guard tab != previousSelectedTab else {
            backToRoot(tab: tab)
            return
        }
        previousSelectedTab = selectedTab
    }

    func backToRoot(tab: TabItem) {
        switch tab {
        case .wallet: resetPath(&wallet)
        case .search:
            if #available(iOS 26, *) {
                resetPath(&search)
            }
        case .collections: resetPath(&collections)
        case .activity: resetPath(&activity)
        case .settings: resetPath(&settings)
        case .markets: resetPath(&markets)
        }
    }

    private func resetPath(_ path: inout NavigationPath) {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }

    func clearAll() {
        for tabItem in TabItem.allCases {
            backToRoot(tab: tabItem)
        }
    }
}
