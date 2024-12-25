// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Keystore

@testable import LockManager

@MainActor
protocol LockWindowManagable {
    var lockModel: LockSceneViewModel { get set }
    var overlayWindow: UIWindow? { get set }

    var showLockScreen: Bool { get }
    var isPrivacyLockVisible: Bool { get }

    func setPhase(phase: ScenePhase)
    func toggleLock(show: Bool)
    func togglePrivacyLock(visible: Bool)
}

extension LockWindowManager: LockWindowManagable {}

@MainActor
class LockWindowManagerMock: LockWindowManagable {
    init(lockModel: LockSceneViewModel) {
        self.lockModel = lockModel
    }

    var lockModel: LockSceneViewModel
    var overlayWindow: UIWindow?
    var showLockScreen: Bool { lockModel.shouldShowLockScreen }
    var isPrivacyLockVisible: Bool { lockModel.isPrivacyLockVisible }

    func setPhase(phase: ScenePhase) {
        guard lockModel.isAutoLockEnabled else {
            lockModel.resetLockState()
            return
        }

        lockModel.handleSceneChange(to: phase)
    }

    func toggleLock(show: Bool) {
        if show {
            if overlayWindow == nil {
                overlayWindow = Self.createOverlayWindow(
                    model: lockModel,
                    isPrivacyLockVisible: lockModel.isPrivacyLockVisible
                )
            }
        } else {
            overlayWindow = nil
        }
    }

    func togglePrivacyLock(visible: Bool) {
        overlayWindow?.alpha = visible ? 1 : 0
    }

    static private func createOverlayWindow(
        model: LockSceneViewModel,
        isPrivacyLockVisible: Bool
    ) -> UIWindow {
        let lockScreen = LockScreenScene(model: model)
        let hostingController = UIHostingController(rootView: lockScreen)

        let lockWindow = UIWindow(frame: .zero)
        lockWindow.rootViewController = hostingController
        lockWindow.windowLevel = UIWindow.Level.alert + 1
        lockWindow.backgroundColor = .clear
        lockWindow.isHidden = false
        lockWindow.alpha = isPrivacyLockVisible ? 1.0 : 0.0

        lockWindow.makeKeyAndVisible()
        return lockWindow
    }

    static func mock(
        isAuthEnabled: Bool = true,
        availableAuth: KeystoreAuthentication = .biometrics,
        isPrivacyLockEnabled: Bool = false,
        lockPeriod: LockPeriod = .oneMinute
    ) -> LockWindowManagerMock {
        let service = MockBiometryAuthenticationService(
            isAuthEnabled: isAuthEnabled,
            availableAuth: availableAuth,
            lockPeriod: lockPeriod,
            isPrivacyLockEnabled: isPrivacyLockEnabled
        )
        let lockModel = LockSceneViewModel(service: service)
        return LockWindowManagerMock(lockModel: lockModel)
    }
}
