// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Keystore
import Store

@Observable
class LockSceneViewModel {
    private let service: BiometryAuthenticatable

    var lastUnlockTime: Date = Date(timeIntervalSince1970: 0)
    var state: LockSceneState

    private var showPlaceholderPreview: Bool = false
    private var inBackground: Bool = false

    init(service: BiometryAuthenticatable = BiometryAuthenticationService()) {
        self.service = service
        self.state = service.isAuthenticationEnabled ? .locked : .unlocked
    }

    var unlockTitle: String { Localized.Lock.unlock }
    var unlockImage: String {
        KeystoreAuthenticationViewModel(authentication: service.availableAuthentication).authenticationImage
    }

    var isAutoLockEnabled: Bool { service.isAuthenticationEnabled }
    var isLocked: Bool { state != .unlocked && isAutoLockEnabled }
    var shouldLock: Bool { Date() > lastUnlockTime && isAutoLockEnabled }
    var shouldShowLockScreen: Bool { isLocked || showPlaceholderPreview }

    var lockPeriod: LockPeriod { service.lockPeriod ?? .immediate }
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
                if state == .unlocked && shouldLock {
                    state = .locked
                }
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
            try await service.authenticate(reason: SecurityViewModel.reason)
            state = .unlocked
            lastUnlockTime = Date.distantFuture
        } catch let error as BiometryAuthenticationError {
            state = error.isAuthenticationCancelled ? .lockedCanceled : .locked
        } catch {
            state = .locked
        }
    }

    func resetLockState() {
        inBackground = false
        showPlaceholderPreview = false
        state = .unlocked
    }
}
