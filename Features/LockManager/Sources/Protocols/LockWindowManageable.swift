// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

@MainActor
public protocol LockWindowManageable: Observable {
    var lockModel: LockSceneViewModel { get set }
    var overlayWindow: UIWindow? { get set }

    var showLockScreen: Bool { get }
    var isPrivacyLockVisible: Bool { get }

    func setPhase(phase: ScenePhase)
    func toggleLock(show: Bool)
    func togglePrivacyLock(visible: Bool)
}
