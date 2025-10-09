// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Keystore
import Localization
import Style

@MainActor
@Observable
public class LockSceneViewModel {
    static private let reason: String = Localized.Settings.Security.authentication

    private let service: any BiometryAuthenticatable

    var lastUnlockTime: Date = Date(timeIntervalSince1970: 0)
    var state: LockSceneState

    private var showPlaceholderPreview: Bool = false
    private var inBackground: Bool = false

    public init(
        service: any BiometryAuthenticatable = BiometryAuthenticationService()
    ) {
        self.service = service
        self.state = service.isAuthenticationEnabled ? .locked : .unlocked
    }

    var unlockTitle: String { Localized.Lock.unlock }
    var unlockImage: String? {
        switch service.availableAuthentication {
        case .biometrics: SystemImage.faceid
        case .passcode: SystemImage.lock
        case .none: .none
        }
    }

    var isAutoLockEnabled: Bool { service.isAuthenticationEnabled }
    var isLocked: Bool { state != .unlocked && isAutoLockEnabled }
    var shouldLock: Bool { Date() > lastUnlockTime && isAutoLockEnabled }
    var shouldShowLockScreen: Bool { isLocked || showPlaceholderPreview }

    var lockPeriod: LockPeriod { service.lockPeriod }
    var isPrivacyLockEnabled: Bool { service.isPrivacyLockEnabled }

    var privacyLockAlpha: CGFloat { isPrivacyLockVisible ? 1 : 0 }

    var isPrivacyLockVisible: Bool {
        guard isAutoLockEnabled else { return false }

        if isPrivacyLockEnabled {
            return state != .unlocked || showPlaceholderPreview
        } else {
            return state == .lockedCanceled || shouldLock
        }
    }
}

// MARK: - Business Logic

extension LockSceneViewModel {
    func handleSceneChange(to phase: ScenePhase) {
        switch phase {
        case .background:
            inBackground = true
            if state == .unlocked && !shouldLock {
                lastUnlockTime = Date().addingTimeInterval(TimeInterval(lockPeriod.value))
            }
        case .active:
            showPlaceholderPreview = false
            if inBackground {
                inBackground = false
            }
            if state == .unlocked && shouldLock {
                state = .locked
            }
        case .inactive:
            showPlaceholderPreview = true
            break
        @unknown default:
            break
        }
    }

    func unlock() async {
        guard state != .unlocking else { return }
        state = .unlocking
        do {
            try await service.authenticate(reason: Self.reason)
            resetLockState()
        } catch let error as BiometryAuthenticationError {
            state = error.isAuthenticationCancelled ? .lockedCanceled : .locked
        } catch {
            state = .locked
        }
    }

    func resetLockState() {
        inBackground = false
        showPlaceholderPreview = false
        lastUnlockTime = .distantFuture
        state = .unlocked
    }
}
