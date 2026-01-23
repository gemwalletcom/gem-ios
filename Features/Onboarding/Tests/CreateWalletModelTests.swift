// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Preferences
import Keystore
import KeystoreTestKit
import StoreTestKit
import WalletServiceTestKit

@testable import Onboarding

@MainActor
struct CreateWalletModelTests {

    @Test
    func createWalletSetsAddressStatus() async throws {
        let model = CreateWalletModel(
            walletService: .mock(keystore: KeystoreMock()),
            avatarService: .init(store: .mock()),
            onComplete: nil
        )

        let wallet = try await model.createWallet(words: LocalKeystore.words)
        let preferences = WalletPreferences(walletId: wallet.walletId)

        #expect(preferences.completeInitialAddressStatus)
        #expect(preferences.completeInitialLoadAssets)
    }
}
