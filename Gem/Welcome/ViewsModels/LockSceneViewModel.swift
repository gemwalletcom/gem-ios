// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Keystore
    
@Observable
class LockSceneViewModel {
    private let service: BiometryAuthentifiable

    var state: LockSceneState
    var shouldLock: Bool = false
    var blur: CGFloat

    init(service: BiometryAuthentifiable = BiometryAuthentificationService()) {
        self.service = service
        self.state = service.isAuthenticationEnabled ? .locked : .unlocked
        self.blur = service.isAuthenticationEnabled ? 10 : 0
    }

    var unlockTitle: String {
        "Unlock"
    }
}

// MARK: - Business Logic

extension LockSceneViewModel {
    var isLocked: Bool {
        state != .unlocked
    }

    func handleSceneChange(to phase: ScenePhase) {
        if phase == .background {
            if state == .unlocked {
                shouldLock = true
            }
        } else if phase == .active {
            if state == .unlocked && shouldLock {
                state = .locked
                shouldLock = false
            }
        }
        blur = Self.blur(phase: phase, isLocked: isLocked)
    }

    func unlock() async {
        guard state != .unlocking else { return }
        state = .unlocking
        do {
            try await service.authenticate(reason: SecurityViewModel.reason)
            state = .unlocked
        } catch let error as BiometryAuthentificationError {
            if error.isAuthCanceled {
                state = .lockedCanceled
            }
        } catch {
            state = .lockedCanceled
            print(error)
        }
    }
}

// MARK: - Private

extension LockSceneViewModel {
    private static func blur(phase: ScenePhase, isLocked: Bool) -> CGFloat {
        if case .active = phase {
            return isLocked ? 10 : 0
        }
        return 10
    }
}
