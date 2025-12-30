// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Testing
import Primitives
import PrimitivesTestKit

@testable import Transfer

struct AmountTransferViewModelTests {

    @Test
    func title() {
        #expect(AmountTransferViewModel(asset: .mock(), action: .send(.mock())).title == "Send")
        #expect(AmountTransferViewModel(asset: .mock(), action: .deposit(.mock())).title == "Deposit")
        #expect(AmountTransferViewModel(asset: .mock(), action: .withdraw(.mock())).title == "Withdraw")
    }

    @Test
    func minimumValue() {
        let usdc = Asset.mock(symbol: "USDC")

        #expect(AmountTransferViewModel(asset: .mock(), action: .send(.mock())).minimumValue == .zero)
        #expect(AmountTransferViewModel(asset: usdc, action: .deposit(.mock())).minimumValue == AmountPerpetualLimits.minDeposit)
        #expect(AmountTransferViewModel(asset: usdc, action: .withdraw(.mock())).minimumValue == AmountPerpetualLimits.minWithdraw)
    }

    @Test
    func availableValue() {
        let assetData = AssetData.mock(balance: .mock(available: 1000, withdrawable: 500))

        #expect(AmountTransferViewModel(asset: .mock(), action: .send(.mock())).availableValue(from: assetData) == 1000)
        #expect(AmountTransferViewModel(asset: .mock(), action: .deposit(.mock())).availableValue(from: assetData) == 1000)
        #expect(AmountTransferViewModel(asset: .mock(), action: .withdraw(.mock())).availableValue(from: assetData) == 500)
    }

    @Test
    func recipientData() {
        let recipient = RecipientData.mock(recipient: .mock(address: "0x123"))
        #expect(AmountTransferViewModel(asset: .mock(), action: .send(recipient)).recipientData().recipient.address == "0x123")
    }

    @Test
    func makeTransferData() throws {
        let send = try AmountTransferViewModel(asset: .mock(), action: .send(.mock())).makeTransferData(value: 100)
        let deposit = try AmountTransferViewModel(asset: .mock(), action: .deposit(.mock())).makeTransferData(value: 200)
        let withdraw = try AmountTransferViewModel(asset: .mock(), action: .withdraw(.mock())).makeTransferData(value: 300)

        #expect(send.type.transactionType == .transfer)
        #expect(deposit.type.transactionType == .transfer)
        #expect(withdraw.type.transactionType == .transfer)
        #expect(send.value == 100)
        #expect(deposit.value == 200)
        #expect(withdraw.value == 300)
    }
}
