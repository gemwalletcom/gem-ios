// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Preferences
import Keystore
import KeystoreTestKit
import NameServiceTestKit
import StoreTestKit
import WalletServiceTestKit

@testable import Onboarding

@MainActor
struct ImportWalletViewModelTests {

    @Test
    func importWalletDoesNotSetAddressStatus() async throws {
        let model = ImportWalletViewModel(
            walletService: .mock(keystore: KeystoreMock()),
            avatarService: .init(store: .mock()),
            nameService: .mock(),
            onComplete: nil
        )

        let wallet = try await model.importWallet(data: WalletImportData(
            name: "Test",
            keystoreType: .phrase(words: LocalKeystore.words, chains: [.tron])
        ))
        let preferences = WalletPreferences(walletId: wallet.walletId)

        #expect(preferences.completeInitialAddressStatus == false)
        #expect(preferences.completeInitialLoadAssets == false)
    }
}
