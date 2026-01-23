// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import Preferences
import Keystore
import KeystoreTestKit
import PrimitivesTestKit
import NameServiceTestKit
import StoreTestKit
import WalletServiceTestKit

@testable import Onboarding

@MainActor
struct ImportWalletViewModelTests {

    @Test
    func importWalletDoesNotSetAddressStatus() async throws {
        let keystore = KeystoreMock()
        let preferences = WalletPreferences(walletId: Wallet.mock().walletId)
        preferences.clear()

        let model = ImportWalletViewModel(
            walletService: .mock(keystore: keystore),
            avatarService: .init(store: .mock()),
            nameService: .mock(),
            onComplete: nil
        )

        _ = try await model.importWallet(data: WalletImportData(
            name: "Test",
            keystoreType: .phrase(words: LocalKeystore.words, chains: [.tron])
        ))

        #expect(preferences.completeInitialAddressStatus == false)
        #expect(preferences.completeInitialLoadAssets == false)
    }
}
