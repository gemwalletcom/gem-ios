// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Keystore
import Foundation
import LocalAuthentication

@testable import Gem

struct LockSceneViewModelTests {

    @Test
    func testInitializationWhenAuthEnabled() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        let viewModel = LockSceneViewModel(service: mockService)
        #expect(viewModel.state == .locked)
    }

    @Test
    func testInitializationWhenAuthDisabled() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: false,
            availableAuth: .none
        )
        let viewModel = LockSceneViewModel(service: mockService)
        #expect(viewModel.state == .unlocked)
    }

    @Test
    func testHandleSceneChangeToBackgroundWhenUnlockedAndShouldNotLock() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.state = .unlocked
        viewModel.lastUnlockTime = Date().addingTimeInterval(1000) // Future date

        viewModel.handleSceneChange(to: .background)

        #expect(viewModel.shouldShowPlaceholder)
        #expect(!viewModel.isLocked)
    }

    @Test
    func testUnlockSuccess() async {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        mockService.shouldAuthenticateSucceed = true
        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.state = .locked

        await viewModel.unlock()

        #expect(viewModel.state == .unlocked)
        #expect(abs(viewModel.lastUnlockTime.timeIntervalSinceReferenceDate - Date(timeIntervalSinceNow: .greatestFiniteMagnitude).timeIntervalSinceReferenceDate) < 1.0)
    }

    @Test
    func testUnlockCancellation() async {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        mockService.errorToThrow = BiometryAuthenticationError.cancelled
        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.state = .locked

        await viewModel.unlock()

        #expect(viewModel.state == .lockedCanceled)
    }

    @Test
    func testUnlockFailure() async {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        mockService.errorToThrow = BiometryAuthenticationError.authenticationFailed
        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.state = .locked

        await viewModel.unlock()

        #expect(viewModel.state == .locked)
    }

    @Test
    func testIsLockedPropertyWhenAuthEnabled() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        let viewModel = LockSceneViewModel(service: mockService)

        viewModel.state = .unlocked
        #expect(!viewModel.isLocked)

        viewModel.state = .locked
        #expect(viewModel.isLocked)

        viewModel.state = .unlocking
        #expect(viewModel.isLocked)
    }

    @Test
    func testIsLockedPropertyWhenAuthDisabled() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: false,
            availableAuth: .none
        )
        let viewModel = LockSceneViewModel(service: mockService)

        viewModel.state = .unlocked
        #expect(!viewModel.isLocked)

        viewModel.state = .locked
        #expect(!viewModel.isLocked)

        viewModel.state = .unlocking
        #expect(!viewModel.isLocked)
    }

    @Test
    func testShouldShowPlaceholder() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        let viewModel = LockSceneViewModel(service: mockService)

        viewModel.state = .unlocked
        viewModel.inBackground = false
        #expect(!viewModel.shouldShowPlaceholder)

        viewModel.state = .locked
        #expect(viewModel.shouldShowPlaceholder)

        viewModel.state = .unlocked
        viewModel.inBackground = true
        #expect(viewModel.shouldShowPlaceholder)
    }

    @Test
    func testHandleSceneChangeWhenAutoLockDisabled() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: false,
            availableAuth: .none
        )
        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.state = .unlocked

        viewModel.handleSceneChange(to: .background)
        #expect(viewModel.inBackground == false)
        #expect(viewModel.state == .unlocked)

        viewModel.handleSceneChange(to: .active)
        #expect(viewModel.inBackground == false)
        #expect(viewModel.state == .unlocked)
    }

    @Test
    func testShouldLockWhenAutoLockDisabled() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: false,
            availableAuth: .none
        )
        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.lastUnlockTime = Date(timeIntervalSince1970: 0)

        #expect(!viewModel.shouldLock)
    }

    @Test
    func testUnlockWhenAutoLockDisabled() async {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: false,
            availableAuth: .none
        )
        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.state = .locked

        await viewModel.unlock()

        #expect(viewModel.state == .unlocked)
    }

    @Test
    func testUnlockWhenAlreadyUnlocking() async {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        var authenticateCalled = false
        mockService.authenticateHandler = {
            authenticateCalled = true
        }
        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.state = .unlocking

        await viewModel.unlock()

        #expect(viewModel.state == .unlocking)
        #expect(!authenticateCalled)
    }

    @Test
    func testRapidSceneChanges() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics,
            lockPeriod: .oneMinute
        )

        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.state = .unlocked
        viewModel.lastUnlockTime = Date().addingTimeInterval(1000) // Future date

        viewModel.handleSceneChange(to: .background)
        viewModel.handleSceneChange(to: .active)
        viewModel.handleSceneChange(to: .background)

        #expect(viewModel.inBackground)
        #expect(viewModel.state == .unlocked)
    }

    @Test
    func testUnlockWithUnexpectedError() async {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        let unexpectedError = NSError(domain: "TestError", code: 999, userInfo: nil)
        mockService.errorToThrow = unexpectedError
        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.state = .locked

        await viewModel.unlock()

        #expect(viewModel.state == .locked)
    }

    @Test
    func testStateTransitionsWithAutoLockDisabled() async {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: false,
            availableAuth: .none
        )
        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.state = .locked

        await viewModel.unlock()
        #expect(viewModel.state == .unlocked)

        viewModel.handleSceneChange(to: .background)
        #expect(viewModel.state == .unlocked)
    }

    @Test
    func testIsAutoLockEnabledProperty() {
        let mockServiceEnabled = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        let viewModelEnabled = LockSceneViewModel(service: mockServiceEnabled)
        #expect(viewModelEnabled.isAutoLockEnabled)

        let mockServiceDisabled = MockBiometryAuthenticationService(
            isAuthEnabled: false,
            availableAuth: .none
        )
        let viewModelDisabled = LockSceneViewModel(service: mockServiceDisabled)
        #expect(!viewModelDisabled.isAutoLockEnabled)
    }

    @Test
    func testShouldLockPropertyWhenAutoLockEnabled() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        let viewModel = LockSceneViewModel(service: mockService)

        viewModel.lastUnlockTime = Date().addingTimeInterval(-1000) // Past date
        #expect(viewModel.shouldLock)

        viewModel.lastUnlockTime = Date().addingTimeInterval(1000) // Future date
        #expect(!viewModel.shouldLock)
    }

    @Test
    func testShouldLockPropertyWhenAutoLockDisabled() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: false,
            availableAuth: .none
        )
        let viewModel = LockSceneViewModel(service: mockService)

        viewModel.lastUnlockTime = Date().addingTimeInterval(-1000) // Past date
        #expect(!viewModel.shouldLock)

        viewModel.lastUnlockTime = Date().addingTimeInterval(1000) // Future date
        #expect(!viewModel.shouldLock)
    }

    @Test
    func testHandleSceneChangeToActiveWhenUnlockedAndShouldLock() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.state = .unlocked
        viewModel.lastUnlockTime = Date(timeIntervalSince1970: 0) // Past date

        viewModel.handleSceneChange(to: .active)

        #expect(viewModel.state == .locked)
    }

    @Test
    func testHandleSceneChangeWhenStateIsNotUnlocked() {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        let viewModel = LockSceneViewModel(service: mockService)
        let initialStates: [LockSceneState] = [.locked, .unlocking, .lockedCanceled]

        for state in initialStates {
            viewModel.state = state
            viewModel.handleSceneChange(to: .background)
            #expect(viewModel.state == state)

            viewModel.handleSceneChange(to: .active)
            #expect(viewModel.state == state)
        }
    }

    @Test
    func testUnlockWithBiometryUnavailableError() async {
        let mockService = MockBiometryAuthenticationService(
            isAuthEnabled: true,
            availableAuth: .biometrics
        )
        mockService.errorToThrow = BiometryAuthenticationError.biometryUnavailable
        let viewModel = LockSceneViewModel(service: mockService)
        viewModel.state = .locked

        await viewModel.unlock()

        #expect(viewModel.state == .locked)
    }
}

// MARK: - Mock

// TODO: - probably move to Keystore TestKip
fileprivate class MockBiometryAuthenticationService: BiometryAuthenticatable {
    var lockPeriod: LockPeriod?

    var isAuthenticationEnabled: Bool
    var availableAuthentication: KeystoreAuthentication

    var shouldAuthenticateSucceed: Bool = true
    var errorToThrow: Error?
    var authenticateHandler: (() -> Void)?

    init(isAuthEnabled: Bool, availableAuth: KeystoreAuthentication, lockPeriod: LockPeriod? = nil) {
        self.isAuthenticationEnabled = isAuthEnabled
        self.availableAuthentication = availableAuth
        self.lockPeriod = lockPeriod
    }

    func enableAuthentication(_ enable: Bool, context: LAContext, reason: String) async throws {
        isAuthenticationEnabled = enable
    }

    func authenticate(context: LAContext, reason: String) async throws {
        authenticateHandler?()
        if let error = errorToThrow {
            throw error
        }
        if !shouldAuthenticateSucceed {
            throw BiometryAuthenticationError.cancelled
        }
    }

    func update(period: LockPeriod) throws {
        self.lockPeriod = period
    }
}
