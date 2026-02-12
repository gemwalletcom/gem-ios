// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Localization
import Primitives

final class AmountEarnViewModel: AmountDataProvidable {
    let asset: Asset
    let action: EarnAmountType

    init(asset: Asset, action: EarnAmountType) {
        self.asset = asset
        self.action = action
    }

    var provider: DelegationValidator {
        switch action {
        case .deposit(let provider): provider
        case .withdraw(let delegation): delegation.validator
        }
    }

    var providerTitle: String {
        Localized.Common.provider
    }

    var title: String {
        switch action {
        case .deposit: Localized.Wallet.deposit
        case .withdraw: Localized.Wallet.withdraw
        }
    }

    var amountType: AmountType {
        .earn(action)
    }

    var minimumValue: BigInt { .zero }
    var canChangeValue: Bool { true }
    var reserveForFee: BigInt { .zero }

    func shouldReserveFee(from assetData: AssetData) -> Bool { false }

    func availableValue(from assetData: AssetData) -> BigInt {
        switch action {
        case .deposit: assetData.balance.available
        case .withdraw(let delegation): delegation.base.balanceValue
        }
    }

    func maxValue(from assetData: AssetData) -> BigInt {
        availableValue(from: assetData)
    }

    func recipientData() -> RecipientData {
        let provider = switch action {
        case .deposit(let provider): provider
        case .withdraw(let delegation): delegation.validator
        }
        return RecipientData(
            recipient: Recipient(name: provider.name, address: provider.id, memo: nil),
            amount: nil
        )
    }

    func makeTransferData(value: BigInt) throws -> TransferData {
        let earnType: EarnType = switch action {
        case .deposit(let provider): .deposit(provider)
        case .withdraw(let delegation): .withdraw(delegation)
        }
        return TransferData(
            type: .earn(asset, earnType),
            recipientData: recipientData(),
            value: value,
            canChangeValue: canChangeValue
        )
    }
}
