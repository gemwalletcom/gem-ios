// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives

@testable import Blockchain

struct TonServiceTests {
    @Test
    func transactionStateConfirmed() throws {
        let transactions = try Bundle.decode(from: "TonTransactionConfirmed", withExtension: "json", in: .module) as TonMessageTransactions
        #expect(Self.state(from: transactions) == .confirmed)
    }
    
    @Test
    func transactionStateFailedAction() throws {
        let transactions = try Bundle.decode(from: "TonTransactionFailed", withExtension: "json", in: .module) as TonMessageTransactions
        #expect(Self.state(from: transactions) == .failed)
    }
    
    @Test
    func transactionStateBounced() throws {
        let transactions = try Bundle.decode(from: "TonTransactionBounced", withExtension: "json", in: .module) as TonMessageTransactions
        #expect(Self.state(from: transactions) == .failed)
    }
    
    @Test
    func transactionStateExitCodeFailed() throws {
        let transactions = try Bundle.decode(from: "TonTransactionExitCodeFailed", withExtension: "json", in: .module) as TonMessageTransactions
        #expect(Self.state(from: transactions) == .failed)
    }
    
    @Test
    func transactionStateAborted() throws {
        let transactions = try Bundle.decode(from: "TonTransactionAborted", withExtension: "json", in: .module) as TonMessageTransactions
        #expect(Self.state(from: transactions) == .failed)
    }
}

// MARK: - Static

extension TonServiceTests {
    static private func state(from transactions: TonMessageTransactions) -> TransactionState? {
        guard let transaction = transactions.transactions.first else { return nil }
        return TonService.transactionState(from: transaction)
    }
}
