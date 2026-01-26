// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Localization
import Primitives

final class AmountYieldViewModel: AmountDataProvidable {
    let asset: Asset
    let action: YieldAction
    let data: EarnData
    let depositedBalance: BigInt?

    init(asset: Asset, action: YieldAction, data: EarnData, depositedBalance: BigInt?) {
        self.asset = asset
        self.action = action
        self.data = data
        self.depositedBalance = depositedBalance
    }

    var title: String {
        switch action {
        case .deposit: Localized.Wallet.deposit
        case .withdraw: Localized.Wallet.withdraw
        }
    }

    var amountType: AmountType {
        .yield(action: action, data: data, depositedBalance: depositedBalance)
    }

    var minimumValue: BigInt { .zero }
    var canChangeValue: Bool { true }
    var reserveForFee: BigInt { .zero }

    func shouldReserveFee(from assetData: AssetData) -> Bool { false }

    func availableValue(from assetData: AssetData) -> BigInt {
        switch action {
        case .deposit: assetData.balance.available
        case .withdraw: depositedBalance ?? .zero
        }
    }

    func maxValue(from assetData: AssetData) -> BigInt {
        availableValue(from: assetData)
    }

    func recipientData() -> RecipientData {
        RecipientData(
            recipient: Recipient(name: data.provider ?? "", address: data.contractAddress ?? "", memo: nil),
            amount: nil
        )
    }

    func makeTransferData(value: BigInt) throws -> TransferData {
        TransferData(
            type: .yield(asset, action, data),
            recipientData: recipientData(),
            value: value,
            canChangeValue: true
        )
    }
}
