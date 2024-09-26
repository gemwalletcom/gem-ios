// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Store

@Observable
@MainActor
class LockWindowManager {
    private let preferences: Preferences

    let lockModel: LockSceneViewModel
    var overlayWindow: UIWindow?

    private var showPrivacyLockOnFirstAppear: Bool = true

    init(lockModel: LockSceneViewModel,
         preferences: Preferences = .main) {
        self.lockModel = lockModel
        self.preferences = preferences
    }

    var showLockScreen: Bool {
        lockModel.shouldShowLockScreen
    }

    var isPrivacyLockVisible: Bool {
        guard lockModel.isAutoLockEnabled else { return false }
        guard preferences.isPrivacyLockEnabled else {
            return lockModel.state == .lockedCanceled
        }
        return true
    }

    func setPhase(phase: ScenePhase) {
        guard lockModel.isAutoLockEnabled else {
            lockModel.resetLockState()
            return
        }

        lockModel.handleSceneChange(to: phase)
    }

    func toggleLock(show: Bool) {
        if show {
            showLock()
        } else {
            hideLock()
        }

        if showPrivacyLockOnFirstAppear {
            showPrivacyLockOnFirstAppear = false
        }
    }

    func togglePrivacyLock(visible: Bool) {
        overlayWindow?.alpha = visible ? 1 : 0
    }
}

// MARK: - Private

extension LockWindowManager {
    private func showLock() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              overlayWindow == nil else { return }

        let firstRun = lockModel.isAutoLockEnabled && !preferences.isPrivacyLockEnabled && showPrivacyLockOnFirstAppear

        overlayWindow = Self.createOverlayWindow(
            model: lockModel,
            isPrivacyLockVisible: isPrivacyLockVisible || firstRun,
            windowScene: windowScene
        )

        // Reset the flag for first appearance after showing
        if showPrivacyLockOnFirstAppear {
            showPrivacyLockOnFirstAppear = false
        }
    }

    private func hideLock() {
        UIView.animate(
            withDuration: 0.15,
            delay: 0.0,
            options: [.curveEaseOut],
            animations: { [weak self] in
                guard let `self` = self else { return }
                overlayWindow?.alpha = 0.0
            },
            completion: { [weak self] _ in
                guard let `self` = self else { return }
                overlayWindow?.isHidden = true
                overlayWindow?.rootViewController = nil
                overlayWindow?.windowScene = nil
                overlayWindow = nil
            }
        )
    }

    static private func createOverlayWindow(model: LockSceneViewModel, isPrivacyLockVisible: Bool, windowScene: UIWindowScene) -> UIWindow {
        let lockScreen = LockScreenScene(model: model)
        let hostingController = UIHostingController(rootView: lockScreen)

        let lockWindow = UIWindow(windowScene: windowScene)
        lockWindow.rootViewController = hostingController
        lockWindow.windowLevel = UIWindow.Level.alert + 1
        lockWindow.backgroundColor = .clear
        lockWindow.isHidden = false
        lockWindow.alpha = isPrivacyLockVisible ? 1.0 : 0.0

        lockWindow.makeKeyAndVisible()
        return lockWindow
    }
}
