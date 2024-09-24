// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import SwiftUI
import UIKit

@testable import Gem

@MainActor
struct LockWindowManagerTests {

    @Test
    func testInitialization() {
        let mockService = MockBiometryAuthenticationService(isAuthEnabled: true, availableAuth: .biometrics)
        let lockModel = LockSceneViewModel(service: mockService)
        let manager = LockWindowManager(lockModel: lockModel)
        #expect(manager.lockModel === lockModel)
        #expect(manager.overlayWindow == nil)
    }

    @Test
    func testShowLockScreen() async {
        let mockService = MockBiometryAuthenticationService(isAuthEnabled: true, availableAuth: .biometrics)
        let lockModel = LockSceneViewModel(service: mockService)
        let manager = LockWindowManager(lockModel: lockModel)

        manager.toggleLock(show: true)

        try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

        #expect(manager.overlayWindow != nil)
        #expect(manager.overlayWindow?.isHidden == false)
        #expect(manager.overlayWindow?.alpha == 1.0)
    }

    @Test
    func testHideLockScreen() async {
        let mockService = MockBiometryAuthenticationService(isAuthEnabled: true, availableAuth: .biometrics)
        let lockModel = LockSceneViewModel(service: mockService)
        let manager = LockWindowManager(lockModel: lockModel)

        manager.toggleLock(show: true)
        manager.toggleLock(show: false)

        try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

        #expect(manager.overlayWindow == nil)
    }

    @Test
    func testSetPhaseActiveWhenAutoLockEnabled() {
        let mockService = MockBiometryAuthenticationService(isAuthEnabled: true, availableAuth: .biometrics)
        let lockModel = LockSceneViewModel(service: mockService)
        let manager = LockWindowManager(lockModel: lockModel)
        manager.setPhase(phase: .active)

        #expect(lockModel.state == .locked)
    }

    @Test
    func testSetPhaseInactive() {
        let mockService = MockBiometryAuthenticationService(isAuthEnabled: true, availableAuth: .biometrics)
        let lockModel = LockSceneViewModel(service: mockService)
        let manager = LockWindowManager(lockModel: lockModel)

        manager.setPhase(phase: .inactive)

        #expect(manager.showLockScreen)
    }

    @Test
    func testSetPhaseBackgroundWhenUnlockedAndShouldNotLock() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics,
            lockPeriod: .oneMinute
        )
        let lockModel = LockSceneViewModel(service: mockService)
        let manager = LockWindowManager(lockModel: lockModel)
        lockModel.state = .unlocked
        lockModel.lastUnlockTime = Date().addingTimeInterval(1000) // Future date, so shouldLock is false

        manager.setPhase(phase: .background)

        let expectedTime = Date().addingTimeInterval(TimeInterval(lockModel.lockPeriod.value))
        let timeDifference = abs(lockModel.lastUnlockTime.timeIntervalSince(expectedTime))
        #expect(timeDifference < 1.0)
    }

    @Test
    func testAutoLockDisabledResetsLockState() {
        let mockService = MockBiometryAuthenticationService(isAuthEnabled: false, availableAuth: .biometrics)
        let lockModel = LockSceneViewModel(service: mockService)
        lockModel.state = .locked

        let manager = LockWindowManager(lockModel: lockModel)

        manager.setPhase(phase: .active)

        #expect(lockModel.state == .unlocked)
        #expect(!lockModel.isLocked)
        #expect(!manager.showLockScreen)
    }

    @Test
    func testShowLockScreenWhenShouldShowLockScreenIsTrue() async {
        let mockService = MockBiometryAuthenticationService(isAuthEnabled: true, availableAuth: .biometrics)
        let lockModel = LockSceneViewModel(service: mockService)
        lockModel.state = .locked
        let manager = LockWindowManager(lockModel: lockModel)

        manager.toggleLock(show: manager.showLockScreen)

        try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))

        #expect(manager.overlayWindow != nil)
        #expect(manager.overlayWindow?.isHidden == false)
    }

    @Test
    func testHideLockScreenWhenShouldShowLockScreenIsFalse() async {
        let mockService = MockBiometryAuthenticationService(isAuthEnabled: true, availableAuth: .biometrics)
        let lockModel = LockSceneViewModel(service: mockService)
        lockModel.state = .unlocked
        let manager = LockWindowManager(lockModel: lockModel)

        manager.toggleLock(show: manager.showLockScreen)

        try? await Task.sleep(nanoseconds: UInt64(0.1 * Double(NSEC_PER_SEC)))

        #expect(manager.overlayWindow == nil)
    }

    @Test
    func testOverlayWindowNotCreatedIfAlreadyExists() async {
        let mockService = MockBiometryAuthenticationService(isAuthEnabled: true, availableAuth: .biometrics)
        let lockModel = LockSceneViewModel(service: mockService)
        let manager = LockWindowManager(lockModel: lockModel)

        manager.toggleLock(show: true)

        try? await Task.sleep(nanoseconds: UInt64(0.1 * Double(NSEC_PER_SEC)))
        let firstWindow = manager.overlayWindow

        manager.toggleLock(show: true)
        let secondWindow = manager.overlayWindow

        #expect(firstWindow === secondWindow)
    }

    @Test
    func testHideLockDoesNothingIfNoOverlayWindow() {
        let mockService = MockBiometryAuthenticationService(isAuthEnabled: true, availableAuth: .biometrics)
        let lockModel = LockSceneViewModel(service: mockService)
        let manager = LockWindowManager(lockModel: lockModel)

        manager.toggleLock(show: false)

        #expect(manager.overlayWindow == nil)
    }

    @Test
    func testShowLockDoesNothingIfOverlayWindowExists() async {
        let mockService = MockBiometryAuthenticationService(isAuthEnabled: true, availableAuth: .biometrics)
        let lockModel = LockSceneViewModel(service: mockService)
        let manager = LockWindowManager(lockModel: lockModel)

        manager.toggleLock(show: true)

        try? await Task.sleep(nanoseconds: UInt64(0.1 * Double(NSEC_PER_SEC)))
        let firstWindow = manager.overlayWindow

        manager.toggleLock(show: true)
        let secondWindow = manager.overlayWindow

        #expect(firstWindow === secondWindow)
    }
}
