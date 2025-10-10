// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
import Primitives
import Formatters

@testable import Validators

struct StakeMinimumValueValidatorTests {
    private let available = BigInt(100)
    private let minimumValue = BigInt(10)
    private let reservedForFee = BigInt(5)
    private let asset = Asset.mockBNB()

    @Test
    func passesWithSufficientBalance() throws {
        let validator = StakeMinimumValueValidator.mock(
            available: available,
            minimumValue: minimumValue,
            reservedForFee: reservedForFee,
            asset: asset
        )
        try validator.validate(BigInt(15))
    }

    @Test
    func throwsBelowMinimum() {
        let validator = StakeMinimumValueValidator.mock(
            available: available,
            minimumValue: minimumValue,
            reservedForFee: reservedForFee,
            asset: asset
        )
        #expect(throws: TransferError.minimumAmount(asset: asset, required: minimumValue)) {
            try validator.validate(BigInt(9))
        }
    }

    @Test
    func throwsInsufficientBalance() {
        let validator = StakeMinimumValueValidator.mock(
            available: BigInt(12),
            minimumValue: minimumValue,
            reservedForFee: reservedForFee,
            asset: asset
        )

        let formatter = ValueFormatter(style: .auto)
        #expect(throws: TransferError.insufficientStakeBalance(
            total: formatter.string(minimumValue + reservedForFee, asset: asset),
            minimum: formatter.string(minimumValue, decimals: asset.decimals.asInt),
            reserved: formatter.string(reservedForFee, decimals: asset.decimals.asInt)
        )) {
            try validator.validate(BigInt(10))
        }
    }
}

extension StakeMinimumValueValidator {
    static func mock(
        available: BigInt,
        minimumValue: BigInt,
        reservedForFee: BigInt,
        asset: Asset
    ) -> StakeMinimumValueValidator {
        StakeMinimumValueValidator(
            available: available,
            minimumValue: minimumValue,
            reservedForFee: reservedForFee,
            asset: asset
        )
    }
}
