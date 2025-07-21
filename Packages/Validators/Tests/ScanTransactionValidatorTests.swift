// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import PrimitivesTestKit

@testable import Validators

struct ScanTransactionValidatorTests {
    @Test
    func throwsMalicious() throws {
        let tx = ScanTransaction.mock(malicious: true)
        let payload = ScanTransactionPayload.mock()
        try expectScanError(tx: tx, payload: payload, expected: .malicious)
    }

    @Test
    func throwsMemoRequiredForTransfer() throws {
        let tx = ScanTransaction.mock(memoRequired: true)
        let payload = ScanTransactionPayload.mock(type: .transfer, chain: .sui)
        try expectScanError(tx: tx, payload: payload, expected: .memoRequired(chain: .sui))
    }

    @Test
    func passesWhenNoIssues() throws {
        let tx = ScanTransaction.mock()
        let payload = ScanTransactionPayload.mock()
        try ScanTransactionValidator.validate(transaction: tx, with: payload)
    }

    @Test
    func swapIgnoresMemoRequired() throws {
        let tx = ScanTransaction.mock(memoRequired: true)
        let payload = ScanTransactionPayload.mock(type: .swap)
        try ScanTransactionValidator.validate(transaction: tx, with: payload)
    }

    @Test
    func maliciousPriority() throws {
        let tx = ScanTransaction.mock(malicious: true, memoRequired: true)
        let payload = ScanTransactionPayload.mock()
        try expectScanError(tx: tx, payload: payload, expected: .malicious)
    }

    private func expectScanError(tx: ScanTransaction, payload: ScanTransactionPayload, expected: ScanTransactionError) throws {
        do {
            try ScanTransactionValidator.validate(transaction: tx, with: payload)
        } catch let error as ScanTransactionError {
            #expect(error == expected)
        }
    }
}
