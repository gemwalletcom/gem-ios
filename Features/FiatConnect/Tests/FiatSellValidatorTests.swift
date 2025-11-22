// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import FiatConnect
import PrimitivesTestKit
import Primitives
import BigInt
import Validators

@testable import FiatConnect

struct FiatSellValidatorTests {

    @Test
    func validationPassesWhenQuoteIsNil() throws {
        let validator = FiatSellValidator.mock(quote: nil)

        #expect(throws: Never.self) {
            try validator.validate(BigInt(100))
        }
    }

    @Test
    func validationPassesWhenCryptoAmountLessThanBalance() throws {
        let validator = FiatSellValidator.mock(
            quote: .mock(fiatAmount: 100, cryptoAmount: 0.5, type: .sell),
            availableBalance: BigInt(100_000_000)
        )

        #expect(throws: Never.self) {
            try validator.validate(BigInt(100))
        }
    }

    @Test
    func validationFailsWhenCryptoAmountExceedsBalance() throws {
        let asset = Asset.mock(decimals: 8)
        let validator = FiatSellValidator.mock(
            quote: .mock(fiatAmount: 100, cryptoAmount: 2.0, type: .sell),
            availableBalance: BigInt(100_000_000),
            asset: asset
        )

        #expect(throws: TransferAmountCalculatorError.insufficientBalance(asset)) {
            try validator.validate(BigInt(100))
        }
    }

    @Test
    func conversionWithHighDecimals() throws {
        let validator = FiatSellValidator.mock(
            quote: .mock(fiatAmount: 1000, cryptoAmount: 0.5, type: .sell),
            availableBalance: BigInt(stringLiteral: "1000000000000000000"),
            asset: .mock(decimals: 18)
        )

        #expect(throws: Never.self) {
            try validator.validate(BigInt(1000))
        }
    }
}

extension FiatSellValidator {
    static func mock(
        quote: FiatQuote? = .mock(type: .sell),
        availableBalance: BigInt = BigInt(100_000_000),
        asset: Asset = .mock(decimals: 8)
    ) -> FiatSellValidator {
        FiatSellValidator(
            quote: quote,
            availableBalance: availableBalance,
            asset: asset
        )
    }
}
