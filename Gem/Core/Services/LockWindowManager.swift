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
}

// MARK: - Private

extension LockWindowManager {
    private func showLock() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              overlayWindow == nil else { return }

        overlayWindow = LockWindowManager.createOverlayWindow(model: lockModel, windowScene: windowScene)
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

    static private func createOverlayWindow(model: LockSceneViewModel, windowScene: UIWindowScene) -> UIWindow {
        let lockScreen = LockScreenScene(model: model)
        let hostingController = UIHostingController(rootView: lockScreen)

        let lockWindow = UIWindow(windowScene: windowScene)
        lockWindow.rootViewController = hostingController
        lockWindow.windowLevel = UIWindow.Level.alert + 1
        lockWindow.backgroundColor = .clear
        lockWindow.isHidden = false


        lockWindow.makeKeyAndVisible()
        return lockWindow
    }
}
