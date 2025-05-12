// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

@Observable
@MainActor
public final class LockWindowManager: LockWindowManageable {
    public var lockModel: LockSceneViewModel
    public var overlayWindow: UIWindow?

    public init(lockModel: LockSceneViewModel) {
        self.lockModel = lockModel
    }

    public var showLockScreen: Bool { lockModel.shouldShowLockScreen }
    public var isPrivacyLockVisible: Bool { lockModel.isPrivacyLockVisible }

    public func setPhase(phase: ScenePhase) {
        guard lockModel.isAutoLockEnabled else {
            lockModel.resetLockState()
            return
        }
        lockModel.handleSceneChange(to: phase)
    }

    public func toggleLock(show: Bool) {
        show ? presentLockWindow() : dismissLockWindow()
    }

    public func togglePrivacyLock(visible: Bool) {
        let alpha: CGFloat = visible ? 1 : 0

        if overlayWindow?.alpha != alpha {
            overlayWindow?.alpha = alpha
        }
    }
}

// MARK: - Private

extension LockWindowManager {
    private func presentLockWindow() {
        if overlayWindow == nil,
           let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            overlayWindow = makeOverlayWindow(in: scene)
        }

        if overlayWindow?.alpha != lockModel.privacyLockAlpha {
            overlayWindow?.alpha = lockModel.privacyLockAlpha
        }
        overlayWindow?.isHidden = false
    }

    private func dismissLockWindow() {
        guard !lockModel.isPrivacyLockVisible else { return }
        overlayWindow?.alpha = 0
        overlayWindow?.isHidden = true
    }

    private func makeOverlayWindow(in scene: UIWindowScene) -> UIWindow {
        let host = UIHostingController(rootView: LockScreenScene(model: lockModel))
        let window = UIWindow(windowScene: scene)
        window.rootViewController = host
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        window.alpha = lockModel.privacyLockAlpha
        window.makeKeyAndVisible()
        return window
    }
}
