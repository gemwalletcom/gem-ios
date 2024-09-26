// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import SwiftUI
import UIKit
import Store
import Keystore

@testable import Gem

@MainActor
struct LockWindowManagerTests {
    @Test
    func testInitialization() {
        let manager = LockWindowManagerMock.mock()
        #expect(manager.overlayWindow == nil)
    }

    @Test
    func testShowLockScreen() async {
        let manager = LockWindowManagerMock.mock()
        manager.toggleLock(show: true)

        try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

        #expect(manager.overlayWindow != nil)
        #expect(manager.overlayWindow?.isHidden == false)
        #expect(manager.overlayWindow?.alpha == 1.0)
        #expect(!manager.isPrivacyLockVisible)
    }

    @Test
    func testHideLockScreen() async {
        let manager = LockWindowManagerMock.mock()
        manager.toggleLock(show: true)
        manager.toggleLock(show: false)

        try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

        #expect(manager.overlayWindow == nil)
    }

    @Test
    func testSetPhaseActiveWhenAutoLockEnabled() {
        let manager = LockWindowManagerMock.mock()
        manager.setPhase(phase: .active)
        #expect(manager.lockModel.state == .locked)
    }

    @Test
    func testSetPhaseInactive() {
        let manager = LockWindowManagerMock.mock()
        manager.setPhase(phase: .inactive)
        #expect(manager.showLockScreen)
    }

    @Test
    func testSetPhaseBackgroundWhenUnlockedAndShouldNotLock() {
        let manager = LockWindowManagerMock.mock(lockPeriod: .oneMinute)
        manager.lockModel.state = .unlocked
        manager.lockModel.lastUnlockTime = Date().addingTimeInterval(1000) // Future date, so shouldLock is false

        manager.setPhase(phase: .background)

        let expectedTime = Date().addingTimeInterval(TimeInterval(manager.lockModel.lockPeriod.value))
        let timeDifference = abs(manager.lockModel.lastUnlockTime.timeIntervalSince(expectedTime))
        #expect(timeDifference < 1.0)
    }

    @Test
    func testAutoLockDisabledResetsLockState() {
        let manager = LockWindowManagerMock.mock(isAuthEnabled: false)
        manager.lockModel.state = .locked
        manager.setPhase(phase: .active)

        #expect(manager.lockModel.state == .unlocked)
        #expect(!manager.lockModel.isLocked)
        #expect(!manager.showLockScreen)
    }

    @Test
    func testShowLockScreenWhenShouldShowLockScreenIsTrue() async {
        let manager = LockWindowManagerMock.mock()
        manager.lockModel.state = .locked
        manager.toggleLock(show: manager.showLockScreen)

        try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

        #expect(manager.overlayWindow != nil)
        #expect(manager.overlayWindow?.isHidden == false)
        #expect(manager.overlayWindow?.alpha == 1.0)
    }

    @Test
    func testHideLockScreenWhenShouldShowLockScreenIsFalse() async {
        let manager = LockWindowManagerMock.mock()
        manager.lockModel.state = .unlocked
        manager.toggleLock(show: manager.showLockScreen)

        try? await Task.sleep(nanoseconds: UInt64(0.1 * Double(NSEC_PER_SEC)))

        #expect(manager.overlayWindow == nil)
    }

    @Test
    func testOverlayWindowNotCreatedIfAlreadyExists() async {
        let manager = LockWindowManagerMock.mock()
        manager.toggleLock(show: true)

        try? await Task.sleep(nanoseconds: UInt64(0.1 * Double(NSEC_PER_SEC)))
        let firstWindow = manager.overlayWindow

        manager.toggleLock(show: true)
        let secondWindow = manager.overlayWindow

        #expect(firstWindow === secondWindow)
    }

    @Test
    func testHideLockDoesNothingIfNoOverlayWindow() {
        let manager = LockWindowManagerMock.mock()
        manager.toggleLock(show: false)
        #expect(manager.overlayWindow == nil)
    }

    @Test
    func testShowLockDoesNothingIfOverlayWindowExists() async {
        let manager = LockWindowManagerMock.mock()
        manager.toggleLock(show: true)
        try? await Task.sleep(nanoseconds: UInt64(0.1 * Double(NSEC_PER_SEC)))
        let firstWindow = manager.overlayWindow

        manager.toggleLock(show: true)
        let secondWindow = manager.overlayWindow

        #expect(firstWindow === secondWindow)
    }

    @Test
    func testPrivacyLockShownOnFirstAppearWhenConditionsMet() async {
        let manager = LockWindowManagerMock.mock(isPrivacyLockEnabled: false)
        manager.toggleLock(show: true)

        try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

        #expect(manager.overlayWindow != nil)
        #expect(manager.overlayWindow?.alpha == 1.0)
        #expect(!manager.isPrivacyLockVisible)
    }

    @Test
    func testPrivacyLockNotShownOnSecondAppear() async {
        let manager = LockWindowManagerMock.mock(isPrivacyLockEnabled: false)
        manager.toggleLock(show: true)

        try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

        #expect(manager.overlayWindow != nil)
        #expect(manager.overlayWindow?.alpha == 1.0)
        #expect(!manager.isPrivacyLockVisible)

        manager.toggleLock(show: false)
        try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

        #expect(manager.overlayWindow == nil)

        manager.toggleLock(show: true)
        try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

        #expect(manager.overlayWindow != nil)
        #expect(manager.overlayWindow?.alpha == 0.0)
        #expect(!manager.isPrivacyLockVisible)
    }

    @Test
    func testPrivacyLockNotShownIfAutoLockDisabled() async {
        let manager = LockWindowManagerMock.mock(isAuthEnabled: false, isPrivacyLockEnabled: true)

        try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))
        #expect(manager.overlayWindow == nil)
        #expect(!manager.isPrivacyLockVisible)
    }

    @Test
     func testPrivacyLockNotShownIfPrivacyLockEnabled() async {
         let manager = LockWindowManagerMock.mock(isPrivacyLockEnabled: true)
         manager.toggleLock(show: true)

         try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

         #expect(manager.overlayWindow != nil)
         #expect(manager.overlayWindow?.alpha == 1.0)
         #expect(manager.isPrivacyLockVisible)
     }

     @Test
     func testPrivacyLockFlagResetAfterFirstAppear() async {
         let manager = LockWindowManagerMock.mock(isPrivacyLockEnabled: false)
         manager.toggleLock(show: true)

         try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

         #expect(manager.overlayWindow == nil)
         #expect(manager.overlayWindow?.alpha == 1)
         #expect(manager.isPrivacyLockVisible)

         manager.toggleLock(show: false)

         try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

         manager.toggleLock(show: true)

         try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

         #expect(manager.overlayWindow != nil)
         #expect(manager.overlayWindow?.alpha == 1)
         #expect(!manager.isPrivacyLockVisible)
     }

    private struct LockWindowManagerMock {
        @MainActor
        static func mock(
            isAuthEnabled: Bool = true,
            availableAuth: KeystoreAuthentication = .biometrics,
            isPrivacyLockEnabled: Bool = false,
            lockPeriod: LockPeriod? = nil
        ) -> LockWindowManager {
            let service = MockBiometryAuthenticationService(
                isAuthEnabled: isAuthEnabled,
                availableAuth: availableAuth,
                lockPeriod: lockPeriod
            )
            let lockModel = LockSceneViewModel(service: service)

            let preferences = Preferences()
            preferences.isPrivacyLockEnabled = isPrivacyLockEnabled
            return LockWindowManager(lockModel: lockModel, preferences: preferences)
        }
    }
 }
