// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Transfer
import PrimitivesComponents

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
        case .transfer, .transferNft: Localized.Transfer.Send.title
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
        }
    }

    var recipientTitle: String {
        switch type {
        case .swap: Localized.Swap.provider
        case .stake: Localized.Stake.validator
        default: Localized.Transfer.to
        }
    }

    var recepientAccount: SimpleAccount {
        switch type {
        case .swap(_, _, let quote, _): SimpleAccount(
            name: recipientName,
            chain: chain,
            address: recipient.address,
            assetImage: SwapProviderViewModel(provider: quote.data.provider).providerImage
        )
        default: SimpleAccount(
            name: recipientName,
            chain: chain,
            address: recipient.address,
            assetImage: .none
        )}
    }

    var appValue: String? {
        switch type {
        case .transfer,
            .transferNft,
            .swap,
            .tokenApprove,
            .stake,
            .account: .none
        case .generic(_, let metadata, _):
            metadata.name
        }
    }

    var websiteURL: URL? {
        switch type {
        case .transfer,
            .transferNft,
            .swap,
            .tokenApprove,
            .stake,
            .account: .none
        case .generic(_, let metadata, _):
            URL(string: metadata.url)
        }
    }

    var shouldShowMemo: Bool {
        switch type {
        case .transfer, .transferNft: chain.isMemoSupported
        case .swap, .tokenApprove, .generic, .stake, .account: false
        }
    }

    var shouldShowRecipient: Bool {
        switch type {
        case .stake(_, let stakeType):
            switch stakeType {
            case .stake, .unstake, .redelegate, .withdraw: true
            case .rewards: false
            }
        case .account: false
        default: true
        }
    }
}


// MARK: - Private

extension TransferDataViewModel {
    private var recipientName: String? {
        switch type {
        case .transfer,
                .transferNft,
                .swap,
                .tokenApprove,
                .generic,
                .account:
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
