// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import PrimitivesTestKit
import TransferTestKit

@testable import Transfer

struct ScanTransactionValidatorTests {
    @Test
    func throwsMalicious() throws {
        let transaction = ScanTransaction.mock(malicious: true)
        try expectScanError(transaction: transaction, asset: .mockEthereum(), memo: nil, expected: .malicious)
    }

    @Test
    func throwsMemoRequiredWhenMissing() throws {
        let transaction = ScanTransaction.mock(memoRequired: true)
        try expectScanError(transaction: transaction, asset: .mockSUI(), memo: nil, expected: .memoRequired(symbol: "SUI"))
    }

    @Test
    func throwsMemoRequiredWhenEmpty() throws {
        let transaction = ScanTransaction.mock(memoRequired: true)
        try expectScanError(transaction: transaction, asset: .mockSUI(), memo: "", expected: .memoRequired(symbol: "SUI"))
    }

    @Test
    func passesWhenMemoProvided() throws {
        let transaction = ScanTransaction.mock(memoRequired: true)
        try ScanTransactionValidator.validate(transaction: transaction, asset: .mockSUI(), memo: "12345")
    }

    @Test
    func throwsMemoRequiredForToken() throws {
        let transaction = ScanTransaction.mock(memoRequired: true)
        try expectScanError(transaction: transaction, asset: .mockEthereumUSDT(), memo: nil, expected: .memoRequired(symbol: "USDT"))
    }

    @Test
    func passesWhenNoIssues() throws {
        let transaction = ScanTransaction.mock()
        try ScanTransactionValidator.validate(transaction: transaction, asset: .mockEthereum(), memo: nil)
    }

    @Test
    func maliciousPriority() throws {
        let transaction = ScanTransaction.mock(malicious: true, memoRequired: true)
        try expectScanError(transaction: transaction, asset: .mockEthereum(), memo: nil, expected: .malicious)
    }

    private func expectScanError(transaction: ScanTransaction, asset: Asset, memo: String?, expected: ScanTransactionError) throws {
        do {
            try ScanTransactionValidator.validate(transaction: transaction, asset: asset, memo: memo)
        } catch let error as ScanTransactionError {
            #expect(error == expected)
        }
    }
}
