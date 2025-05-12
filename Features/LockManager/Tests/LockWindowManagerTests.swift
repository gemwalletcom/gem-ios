// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import SwiftUI
import Keystore
@testable import LockManager

@MainActor
struct LockWindowManagerTests {
    @Test
    func testInitialization() {
        let manager = LockWindowManagerMock.mock()
        #expect(manager.overlayWindow == nil)
    }

    @Test
    func testShowLockScreenCreatesWindow() {
        let manager = LockWindowManagerMock.mock()
        manager.toggleLock(show: true)

        #expect(manager.overlayWindow != nil)
        #expect(manager.overlayWindow?.isHidden == false)
        #expect(manager.overlayWindow?.alpha == 1)
    }

    @Test
    func testDismissWhileLockedDoesNotRemoveWindow() {
        let manager = LockWindowManagerMock.mock()
        manager.toggleLock(show: true)
        manager.toggleLock(show: false)

        #expect(manager.overlayWindow != nil)
        #expect(manager.overlayWindow?.alpha == 1)
    }

    @Test
    func testDismissAfterUnlockRemovesWindow() {
        let manager = LockWindowManagerMock.mock()
        manager.toggleLock(show: true)

        manager.lockModel.state  = .unlocked
        manager.lockModel.lastUnlockTime = .distantFuture
        manager.toggleLock(show: false)

        #expect(manager.overlayWindow == nil)
    }

    @Test
    func testSetPhaseInactiveShowsPlaceholder() {
        let manager = LockWindowManagerMock.mock()
        manager.setPhase(phase: .inactive)
        #expect(manager.showLockScreen)
    }

    @Test
    func testSetPhaseActiveAutoLocks() {
        let manager = LockWindowManagerMock.mock()
        manager.setPhase(phase: .active)
        #expect(manager.lockModel.state == .locked)
    }

    @Test
    func testBackgroundSchedulesAutoLock() {
        let manager = LockWindowManagerMock.mock(lockPeriod: .oneMinute)
        manager.lockModel.state = .unlocked
        manager.lockModel.lastUnlockTime = .distantFuture

        manager.setPhase(phase: .background)

        let expected = Date().addingTimeInterval(TimeInterval(manager.lockModel.lockPeriod.value))

        #expect(abs(manager.lockModel.lastUnlockTime.timeIntervalSince(expected)) < 1)
    }

    @Test
    func testAutoLockDisabledResetsState() {
        let manager = LockWindowManagerMock.mock(isAuthEnabled: false)
        manager.lockModel.state = .locked
        manager.setPhase(phase: .active)

        #expect(manager.lockModel.state == .unlocked)
        #expect(!manager.showLockScreen)
    }

    @Test
    func testOverlayWindowIsReused() {
        let manager = LockWindowManagerMock.mock()
        manager.toggleLock(show: true)
        let first = manager.overlayWindow

        manager.toggleLock(show: true)
        #expect(first === manager.overlayWindow)
    }

    @Test
    func testOverlayVisibleWhenPrivacySwitchDisabled() {
        let manager = LockWindowManagerMock.mock(isPrivacyLockEnabled: false)
        manager.toggleLock(show: true)

        #expect(manager.overlayWindow?.alpha == 1)
        #expect(manager.isPrivacyLockVisible)
    }

    @Test
    func testOverlayVisibleWhenPrivacySwitchEnabled() {
        let manager = LockWindowManagerMock.mock(isPrivacyLockEnabled: true)
        manager.toggleLock(show: true)

        #expect(manager.overlayWindow?.alpha == 1)
        #expect(manager.isPrivacyLockVisible)
    }

    @Test
    func testSecondPresentKeepsOverlayIfConditionsUnchanged() {
        let manager = LockWindowManagerMock.mock(isPrivacyLockEnabled: false)
        manager.toggleLock(show: true)
        manager.toggleLock(show: false)
        manager.toggleLock(show: true)

        #expect(manager.overlayWindow != nil)
        #expect(manager.overlayWindow?.alpha == 1)
        #expect(manager.isPrivacyLockVisible)
    }

    @Test
    func testNoOverlayWhenAuthenticationDisabled() {
        let manager = LockWindowManagerMock.mock(isAuthEnabled: false,
                                             isPrivacyLockEnabled: true)

        #expect(manager.isPrivacyLockVisible == false)
        #expect(manager.overlayWindow == nil)
    }
}
