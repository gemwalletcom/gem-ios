// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

private struct LockWindowManagerViewModifier: ViewModifier {
    @Environment(\.scenePhase) var scenePhase
    private let lockManager: any LockWindowManageable

    init(lockManager: any LockWindowManageable) {
        self.lockManager = lockManager
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, newPhase in
                lockManager.setPhase(phase: newPhase)
            }
            .onChange(of: lockManager.isPrivacyLockVisible) { _, visible in
                lockManager.togglePrivacyLock(visible: visible)
            }
            .onChange(of: lockManager.showLockScreen, initial: true) { _, showLockScreen in
                lockManager.toggleLock(show: showLockScreen)
            }
    }
}

public extension View {
    func lockManaged(by lockManager: any LockWindowManageable) -> some View {
        self.modifier(LockWindowManagerViewModifier(lockManager: lockManager))
    }
}
