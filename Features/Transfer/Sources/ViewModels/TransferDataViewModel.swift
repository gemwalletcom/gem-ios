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
        case .deposit: "Deposit"
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
            }
        }
    }

    var recipientTitle: String {
        switch type {
        case .swap: Localized.Common.provider
        case .stake: Localized.Stake.validator
        default: Localized.Transfer.to
        }
    }

    var recepientAccount: SimpleAccount {
        SimpleAccount(
            name: recipientName,
            chain: chain,
            address: recipient.address,
            assetImage: .none
        )
    }

    var recipientMode: AddressListItemViewModel.Mode {
        switch type {
        case .transfer,
                .deposit,
                .transferNft,
                .tokenApprove,
                .stake,
                .account,
                .generic,
                .perpetual: .auto(addressStyle: .short)
        case .swap: .nameOrAddress
        }
    }

    var appValue: String? {
        switch type {
        case .transfer,
            .deposit,
            .transferNft,
            .swap,
            .tokenApprove,
            .stake,
            .account,
            .perpetual: .none
        case .generic(_, let metadata, _):
            metadata.shortName
        }
    }

    var websiteURL: URL? {
        switch type {
        case .transfer,
            .deposit,
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

    var shouldShowMemo: Bool {
        switch type {
        case .transfer, .deposit: chain.isMemoSupported
        case .transferNft, .swap, .tokenApprove, .generic, .account, .stake, .perpetual: false
        }
    }

    var shouldShowRecipient: Bool {
        switch type {
        case .stake(_, let stakeType):
            switch stakeType {
            case .stake, .unstake, .redelegate, .withdraw: true
            case .rewards: false
            }
        case .account,
            .swap,
            .perpetual: false
        case .transfer,
            .transferNft,
            .deposit,
            .generic,
            .tokenApprove: true
        }
    }
    
    var appAssetImage: AssetImage? {
        switch type {
        case .transfer,
                .deposit,
                .transferNft,
                .swap,
                .tokenApprove,
                .stake,
                .account,
                .perpetual:
                .none
        case let .generic(_, session, _):
            AssetImage(imageURL: session.icon.asURL)
        }
    }

    func availableValue(metadata: TransferDataMetadata?) -> BigInt {
        switch type {
        case .transfer,
                .deposit,
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
            case .unstake(let delegation), .redelegate(let delegation, _), .withdraw(let delegation): delegation.base.balanceValue
            case .rewards: data.value
            case .stake: metadata?.available ?? .zero
            }
        }
    }
}

// MARK: - Private

extension TransferDataViewModel {
    private var recipientName: String? {
        switch type {
        case .transfer,
                .deposit,
                .transferNft,
                .swap,
                .tokenApprove,
                .generic,
                .account,
                .perpetual:
            recipient.name ?? recipient.address
        case .stake(_, let stakeType):
            switch stakeType {
            case .stake(let validator):
                validator.name
            case .unstake(let delegation):
                delegation.validator.name
            case .redelegate(_, let toValidator):
                toValidator.name
            case .withdraw(let delegation):
                delegation.validator.name
            case .rewards:
                    .none
            }
        }
    }
}
