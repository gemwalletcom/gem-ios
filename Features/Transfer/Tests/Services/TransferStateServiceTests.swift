// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Transfer
import Primitives
import PrimitivesTestKit
import TransferTestKit

@MainActor
struct TransferStateServiceTests {

    @Test
    func addsExecutionAndUpdatesPresenter() async {
        let (presenter, service) = await makeService()

        await service.add(transferData: .mock(), wallet: .mock()) {}

        #expect(presenter.executions.count == 1)
        #expect(presenter.executions.first?.wallet.walletId == .mock())
    }

    @Test
    func removesExecution() async {
        let (presenter, service) = await makeService()

        await service.add(transferData: .mock(), wallet: .mock()) {}
        await service.remove(execution: presenter.executions.first!)

        #expect(presenter.executions.isEmpty)
    }

    @Test
    func filtersExecutionsByCurrentWallet() async {
        let (presenter, service) = await makeService()

        await service.add(transferData: .mock(recipient: .mock(recipient: .mock(address: "address1"))), wallet: .mock()) {}
        await service.add(transferData: .mock(recipient: .mock(recipient: .mock(address: "address2"))), wallet: .mock(id: "wallet2")) {}

        #expect(presenter.executions.count == 1)
        #expect(presenter.executions.first?.wallet.walletId == .mock())
    }

    @Test
    func switchingWalletUpdatesExecutions() async {
        let (presenter, service) = await makeService()

        await service.add(transferData: .mock(recipient: .mock(recipient: .mock(address: "address1"))), wallet: .mock()) {}
        await service.add(transferData: .mock(recipient: .mock(recipient: .mock(address: "address2"))), wallet: .mock(id: "wallet2")) {}

        #expect(presenter.executions.count == 1)
        #expect(presenter.executions.first?.wallet.walletId == .mock())

        await service.setCurrentWallet(id: .mock(id: "wallet2"))

        #expect(presenter.executions.count == 1)
        #expect(presenter.executions.first?.wallet.walletId == .mock(id: "wallet2"))
    }

    @Test
    func executionSuccessStateTransition() async {
        let (presenter, service) = await makeService()

        await service.add(transferData: .mock(), wallet: .mock()) {}
        
        #expect(presenter.executions.first?.state.priority == ExecutionState.executing.priority)

        try? await Task.sleep(for: .milliseconds(50))
        #expect(presenter.executions.first?.state.priority == ExecutionState.success.priority)
    }

    @Test
    func executionErrorStateTransition() async {
        let (presenter, service) = await makeService()

        await service.add(transferData: .mock(), wallet: .mock()) {
            throw AnyError("test error")
        }

        try? await Task.sleep(for: .milliseconds(50))
        #expect(presenter.executions.first?.state.priority == ExecutionState.error(AnyError("test error")).priority)
    }

    @Test
    func multipleExecutionsForSameWallet() async {
        let (presenter, service) = await makeService()

        await service.add(transferData: .mock(recipient: .mock(recipient: .mock(address: "address1"))), wallet: .mock()) {}
        await service.add(transferData: .mock(recipient: .mock(recipient: .mock(address: "address2"))), wallet: .mock()) {}

        #expect(presenter.executions.count == 2)
    }

    @Test
    func displayExecutionPriority() async {
        let (presenter, service) = await makeService()

        await service.add(transferData: .mock(recipient: .mock(recipient: .mock(address: "address1"))), wallet: .mock()) {}
        await service.add(transferData: .mock(recipient: .mock(recipient: .mock(address: "address2"))), wallet: .mock()) {
            throw AnyError("test error")
        }

        try? await Task.sleep(for: .milliseconds(50))
        #expect(presenter.executions.displayExecution?.state.priority == ExecutionState.error(AnyError("")).priority)
    }
    
    private func makeService() async -> (TransferStatePresenter, TransferStateService) {
        let presenter = TransferStatePresenter.mock()
        let service = TransferStateService.mock(presenter: presenter)
        await service.setCurrentWallet(id: .mock())
        return (presenter, service)
    }
}
