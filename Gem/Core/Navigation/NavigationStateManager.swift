// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

protocol NavigationStateManagable: Observation.Observable, AnyObject {
    var wallet: NavigationPath { get set }
    var activity: NavigationPath { get set }
    var settings: NavigationPath { get set }

    var selectedTab: TabItem { get set }
    var previousSelectedTab: TabItem { get set }

    init(initialSelecedTab: TabItem)

    func select(tab: TabItem)
    func backToRoot(tab: TabItem)
    func clearAll()
}

// MARK: - NavigationStateManagable

@Observable
final class NavigationStateManager: NavigationStateManagable {
    var wallet = NavigationPath()
    var collections = NavigationPath()
    var activity = NavigationPath()
    var settings = NavigationPath()
    var markets = NavigationPath()

    var selectedTab: TabItem
    var previousSelectedTab: TabItem

    required init(initialSelecedTab: TabItem) {
        self.selectedTab = initialSelecedTab
        self.previousSelectedTab = initialSelecedTab
    }
}

// MARK: - Business Logic

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
