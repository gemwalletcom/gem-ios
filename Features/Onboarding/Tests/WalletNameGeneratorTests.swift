// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import WalletService
import WalletServiceTestKit

@testable import Onboarding

struct WalletNameGeneratorTests {

    @Test
    func walletNameWhenEmpty() {
        let generator = WalletNameGenerator(type: .multicoin, walletService: .mock())
        let name = ""

        let result = name.isEmpty ? generator.name : name

        #expect(result == "Wallet #1")
    }

    @Test
    func walletNameWhenProvided() {
        let generator = WalletNameGenerator(type: .multicoin, walletService: .mock())
        let name = "My Wallet"

        let result = name.isEmpty ? generator.name : name

        #expect(result == "My Wallet")
    }
}
