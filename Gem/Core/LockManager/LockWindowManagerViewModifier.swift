// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

private struct LockWindowManagerViewModifier: ViewModifier {
    @Environment(\.scenePhase) var scenePhase
    let lockManager: LockWindowManager

    init(lockManager: LockWindowManager) {
        self.lockManager = lockManager
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                lockManager.toggleLock(show: lockManager.showLockScreen)
            }
            .onChange(of: scenePhase) { _, newPhase in
                lockManager.setPhase(phase: newPhase)
            }
            .onChange(of: lockManager.isPrivacyLockVisible) { _, visible in
                lockManager.togglePrivacyLock(visible: visible)
            }
            .onChange(of: lockManager.showLockScreen) { _, showLockScreen in
                lockManager.toggleLock(show: showLockScreen)
            }
    }
}

extension View {
    func lockManaged(by lockManager: LockWindowManager) -> some View {
        self.modifier(LockWindowManagerViewModifier(lockManager: lockManager))
    }
}
