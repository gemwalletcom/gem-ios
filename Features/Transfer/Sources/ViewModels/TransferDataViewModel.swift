// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import PrimitivesComponents
import Components
import BigInt

struct TransferDataViewModel {
    let data: TransferData

    init(data: TransferData) {
        self.data = data
    }

    var type: TransferDataType { data.type }
    var recipientData: RecipientData { data.recipientData }
    var recipient: Recipient { recipientData.recipient }
    var asset: Asset { data.type.asset }
    var memo: String? { recipientData.recipient.memo }
    var chain: Chain { data.chain }
    var chainType: ChainType { chain.type }
    var chainAsset: Asset { chain.asset }

    var title: String {
        switch type {
        case .transfer: Localized.Transfer.Send.title
        case .deposit: Localized.Wallet.deposit
        case .withdrawal: Localized.Wallet.withdraw
        case .transferNft: Localized.Transfer.Send.title
        case .swap, .tokenApprove: Localized.Wallet.swap
        //case .approval: Localized.Transfer.Approve.title
        case .generic: Localized.Transfer.Approve.title
        case .stake(_, let type):
            switch type {
            case .stake: Localized.Transfer.Stake.title
            case .unstake: Localized.Transfer.Unstake.title
            case .redelegate: Localized.Transfer.Redelegate.title
            case .rewards: Localized.Transfer.ClaimRewards.title
            case .withdraw: Localized.Transfer.Withdraw.title
            case .freeze(let data):
                switch data.freezeType {
                case .freeze: Localized.Transfer.Freeze.title
                case .unfreeze: Localized.Transfer.Unfreeze.title
                }
            }
        case .account(_, let type):
            switch type {
            case .activate: Localized.Transfer.ActivateAsset.title
            }
        case .perpetual(_, let type):
            switch type {
            case .open(let data): switch data.direction {
                case .short: Localized.Perpetual.short
                case .long: Localized.Perpetual.long
            }
            case .close: Localized.Perpetual.closePosition
            case .modify(_): "Modify position" // TODO: - Add localization
            }
        }
    }

    var websiteURL: URL? {
        switch type {
        case .transfer,
            .deposit,
            .withdrawal,
            .transferNft,
            .swap,
            .tokenApprove,
            .stake,
            .account,
            .perpetual: .none
        case .generic(_, let metadata, _):
            URL(string: metadata.url)
        }
    }

    func availableValue(metadata: TransferDataMetadata?) -> BigInt {
        switch type {
        case .transfer,
                .deposit,
                .withdrawal,
                .swap,
                .tokenApprove,
                .generic,
                .transferNft,
                .perpetual: metadata?.available ?? .zero
        case .account(_, let type):
            switch type {
            case .activate: metadata?.available ?? .zero
            }
        case .stake(_, let stakeType):
            switch stakeType {
            case .unstake(let delegation): delegation.base.balanceValue
            case .redelegate(let data): data.delegation.base.balanceValue
            case .withdraw(let delegation): delegation.base.balanceValue
            case .rewards: data.value
            case .stake: metadata?.available ?? .zero
            case .freeze: metadata?.available ?? .zero
            }
        }
    }
}
