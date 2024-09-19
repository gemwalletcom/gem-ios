// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Keystore
import Store

@Observable
class LockSceneViewModel {
    private let service: BiometryAuthenticatable

    var lastUnlockTime: Date = Date(timeIntervalSince1970: 0)
    var state: LockSceneState
    var inBackground: Bool = false

    init(service: BiometryAuthenticatable = BiometryAuthenticationService()) {
        self.service = service
        self.state = service.isAuthenticationEnabled ? .locked : .unlocked
    }

    var unlockTitle: String { Localized.Lock.unlock }

    var isAutoLockEnabled: Bool { service.isAuthenticationEnabled }
    var isLocked: Bool { state != .unlocked && isAutoLockEnabled }

    var shouldShowPlaceholder: Bool { isLocked || (inBackground && shouldLock) }
    var shouldLock: Bool { Date() > lastUnlockTime && isAutoLockEnabled }
    var lockPeriod: LockPeriod { service.lockPeriod ?? .immediate }
}

// MARK: - Business Logic

extension LockSceneViewModel {
    func handleSceneChange(to phase: ScenePhase) {
        guard isAutoLockEnabled else { return }
        if phase == .background {
            inBackground = true
            if state == .unlocked && !shouldLock {
                lastUnlockTime = Date().addingTimeInterval(TimeInterval(lockPeriod.value))
            }
        } else if phase == .active {
            inBackground = false
            if state == .unlocked && shouldLock {
                state = .locked
            }
        }
    }

    func unlock() async {
        guard state != .unlocking else { return }
        state = .unlocking
        do {
            try await service.authenticate(reason: SecurityViewModel.reason)
            state = .unlocked
            lastUnlockTime = Date(timeIntervalSinceNow: .greatestFiniteMagnitude)
        } catch let error as BiometryAuthenticationError {
            state = error.isAuthenticationCancelled ? .lockedCanceled : .locked
        } catch {
            state = .locked
        }
    }
}
