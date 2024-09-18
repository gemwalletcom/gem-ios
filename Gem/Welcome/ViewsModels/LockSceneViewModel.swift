// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Keystore
import Store

@Observable
class LockSceneViewModel {
    private let service: BiometryAuthenticable
    private let preferences: Preferences

    var lastUnlockTime: Date = Date(timeIntervalSince1970: 0)
    var state: LockSceneState
    var inBackground: Bool = false

    init(preferences: Preferences = Preferences.main,
         service: BiometryAuthenticable = BiometryAuthenticationService()) {
        self.service = service
        self.preferences = preferences
        self.state = service.isAuthenticationEnabled ? .locked : .unlocked
    }

    var unlockTitle: String { Localized.Lock.unlock }
}

// MARK: - Business Logic

extension LockSceneViewModel {
    var isAutoLockEnabled: Bool { service.isAuthenticationEnabled }
    var shouldShowPlaceholder: Bool { isLocked || inBackground }
    var isLocked: Bool { state != .unlocked && isAutoLockEnabled }
    var shouldLock: Bool { Date() > lastUnlockTime && isAutoLockEnabled }

    func handleSceneChange(to phase: ScenePhase) {
        guard isAutoLockEnabled else { return }
        if phase == .background {
            inBackground = true
            if state == .unlocked && !shouldLock {
                lastUnlockTime = Date().addingTimeInterval(TimeInterval(lockOption.rawValue))
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
            state = error.isAuthCancelled ? .lockedCanceled : .locked
        } catch {
            state = .locked
        }
    }
}

// MARK: - Private

extension LockSceneViewModel {
    private var lockOption: LockOption {
        LockOption(rawValue: preferences.authenticationLockOption) ?? .immediate
    }
}
