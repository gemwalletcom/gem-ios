// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import PrimitivesTestKit

@testable import Transfer

struct ScanTransactionValidatorTests {
    @Test
    func throwsMalicious() throws {
        let transaction = ScanTransaction.mock(malicious: true)
        let payload = ScanTransactionPayload.mock()
        try expectScanError(transaction: transaction, payload: payload, expected: .malicious)
    }

    @Test
    func throwsMemoRequiredForTransfer() throws {
        let transaction = ScanTransaction.mock(memoRequired: true)
        let payload = ScanTransactionPayload.mock(type: .transfer, chain: .sui)
        try expectScanError(transaction: transaction, payload: payload, expected: .memoRequired(symbol: "SUI"))
    }

    @Test
    func passesWhenNoIssues() throws {
        let transaction = ScanTransaction.mock()
        let payload = ScanTransactionPayload.mock()
        try ScanTransactionValidator.validate(transaction: transaction, with: payload)
    }

    @Test
    func swapIgnoresMemoRequired() throws {
        let transaction = ScanTransaction.mock(memoRequired: true)
        let payload = ScanTransactionPayload.mock(type: .swap)
        try ScanTransactionValidator.validate(transaction: transaction, with: payload)
    }

    @Test
    func maliciousPriority() throws {
        let transaction = ScanTransaction.mock(malicious: true, memoRequired: true)
        let payload = ScanTransactionPayload.mock()
        try expectScanError(transaction: transaction, payload: payload, expected: .malicious)
    }

    private func expectScanError(transaction: ScanTransaction, payload: ScanTransactionPayload, expected: ScanTransactionError) throws {
        do {
            try ScanTransactionValidator.validate(transaction: transaction, with: payload)
        } catch let error as ScanTransactionError {
            #expect(error == expected)
        }
    }
}
