// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Keystore
@testable import LockManager

@MainActor
final class LockWindowManagerMock: LockWindowManageable {

    var lockModel: LockSceneViewModel
    var overlayWindow: UIWindow?

    init(lockModel: LockSceneViewModel) {
        self.lockModel = lockModel
    }

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
        show ? present() : dismiss()
    }

    func togglePrivacyLock(visible: Bool) {
        let alpha: CGFloat = visible ? 1 : 0
        if overlayWindow?.alpha != alpha { overlayWindow?.alpha = alpha }
    }

    private func present() {
        if overlayWindow == nil {
            overlayWindow = Self.makeWindow(
                model: lockModel,
                visible: lockModel.isPrivacyLockVisible
            )
        }
        togglePrivacyLock(visible: lockModel.isPrivacyLockVisible)
        overlayWindow?.isHidden = false
    }

    private func dismiss() {
        guard !lockModel.isPrivacyLockVisible else { return }
        overlayWindow?.alpha   = 0
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }

    private static func makeWindow(model: LockSceneViewModel, visible: Bool) -> UIWindow {
        let host = UIHostingController(rootView: LockScreenScene(model: model))
        let window = UIWindow(frame: .zero)
        window.rootViewController = host
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        window.alpha = visible ? 1 : 0
        window.makeKeyAndVisible()
        return window
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
        return .init(lockModel: LockSceneViewModel(service: service))
    }
}
