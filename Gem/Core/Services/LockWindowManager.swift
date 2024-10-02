// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

@Observable
@MainActor
class LockWindowManager {
    let lockModel: LockSceneViewModel
    var overlayWindow: UIWindow?

    init(lockModel: LockSceneViewModel) {
        self.lockModel = lockModel
    }

    var showLockScreen: Bool {
        lockModel.shouldShowLockScreen
    }

    var isPrivacyLockVisible: Bool {
        lockModel.isPrivacyLockVisible
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

        overlayWindow = Self.createOverlayWindow(
            model: lockModel,
            isPrivacyLockVisible: lockModel.isPrivacyLockVisible,
            windowScene: windowScene
        )
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
