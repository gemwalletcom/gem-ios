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
}

// MARK: - NavigationStateManagable

@Observable
final class NavigationStateManager: NavigationStateManagable {
    var wallet = NavigationPath()
    var activity = NavigationPath()
    var settings = NavigationPath()

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
        case .wallet:
            guard !wallet.isEmpty else { return }
            wallet.removeLast(wallet.count)
        case .activity:
            guard !activity.isEmpty else {
                return
            }
            activity.removeLast(activity.count)
        case .settings:
            guard !settings.isEmpty else {
                return
            }
            settings.removeLast(settings.count)
        }
    }
}
