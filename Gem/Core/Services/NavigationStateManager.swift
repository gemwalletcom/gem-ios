// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

typealias TabScrollToTopId = TabItem

protocol NavigationStateManagable: Observable {
    var walletNavigationPath: NavigationPath { get set }
    var activityNavigationPath: NavigationPath { get set }
    var settingsNavigationPath: NavigationPath { get set }

    var tabViewSelection: Binding<TabItem> { get }
    var scrollToTop: Bool { get set }
    var selectedTab: TabItem { get set }

    init(initialSelecedTab: TabItem)
}

@Observable
final class NavigationStateManager: NavigationStateManagable {
    var walletNavigationPath = NavigationPath()
    var activityNavigationPath = NavigationPath()
    var settingsNavigationPath = NavigationPath()

    var scrollToTop: Bool
    var selectedTab: TabItem
    private var previousSelectedTab: TabItem

    var tabViewSelection: Binding<TabItem> {
        return Binding(
            get: { [self] in
                self.selectedTab
            },
            set: { [self] in
                self.selectedTab = $0
                onSelectNewTab()
            }
        )
    }

    init(initialSelecedTab: TabItem) {
        self.selectedTab = initialSelecedTab
        self.previousSelectedTab = initialSelecedTab
        self.scrollToTop = false
    }
}

// MARK: - Actions

extension NavigationStateManager {
    private func onSelectNewTab() {
        // back to root if selected same tab, if some routes already push
        guard selectedTab != previousSelectedTab else {
            handleSelection(for: selectedTab)
            return
        }
        previousSelectedTab = selectedTab
    }
}

// MARK: - Effects

extension NavigationStateManager {
    private func handleSelection(for tab: TabItem) {
        switch tab {
        case .wallet:
            guard !walletNavigationPath.isEmpty else {
                scrollToTop.toggle()
                return
            }
            walletNavigationPath.removeLast(walletNavigationPath.count)
        case .activity:
            guard !activityNavigationPath.isEmpty else {
                scrollToTop.toggle()
                return
            }
            activityNavigationPath.removeLast(activityNavigationPath.count)
        case .settings:
            guard !settingsNavigationPath.isEmpty else {
                scrollToTop.toggle()
                return
            }
            settingsNavigationPath.removeLast(settingsNavigationPath.count)
        }
    }
}
