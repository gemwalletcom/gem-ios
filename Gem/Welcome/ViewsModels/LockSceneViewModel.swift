// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Keystore
import Store

@Observable
class LockSceneViewModel {
    private static var disabledBlur: CGFloat = 10

    private let service: BiometryAuthentifiable
    private let preferences: Preferences

    private var lastUnlockTime: Date = Date(timeIntervalSince1970: 0)

    var state: LockSceneState
    var blur: CGFloat

    init(preferences: Preferences = Preferences.main,
         service: BiometryAuthentifiable = BiometryAuthentificationService()) {
        self.service = service
        self.preferences = preferences
        self.state = service.isAuthenticationEnabled ? .locked : .unlocked
        self.blur = service.isAuthenticationEnabled ? LockSceneViewModel.disabledBlur : .zero
    }

    // TODO: - localize
    var unlockTitle: String { "Unlock" }
}

// MARK: - Business Logic

extension LockSceneViewModel {
    var isLocked: Bool {
        state != .unlocked
    }

    var shouldLock: Bool {
        Date() > lastUnlockTime
    }

    func handleSceneChange(to phase: ScenePhase) {
        if phase == .background {
            if state == .unlocked && !shouldLock {
                lastUnlockTime = Date().addingTimeInterval(TimeInterval(lockOption.rawValue))
            }
        } else if phase == .active {
            if state == .unlocked && shouldLock {
                state = .locked
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
            lastUnlockTime = Date(timeIntervalSinceNow: .greatestFiniteMagnitude)
        } catch let error as BiometryAuthentificationError {
            if error.isAuthCanceled {
                state = .lockedCanceled
            }
        } catch {
            state = .lockedCanceled
        }
    }
}

// MARK: - Private

extension LockSceneViewModel {
    private var lockOption: LockOption {
        LockOption(rawValue: preferences.authentificationLockOption) ?? .immediate
    }

    private static func blur(phase: ScenePhase, isLocked: Bool) -> CGFloat {
        if case .active = phase {
            return isLocked ? LockSceneViewModel.disabledBlur : .zero
        }
        return LockSceneViewModel.disabledBlur
    }
}
