// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Localization
import Primitives
import PrimitivesComponents

struct ConfirmRecipientViewModel {
    private let model: TransferDataViewModel
    private let addressName: AddressName?
    private let addressLink: BlockExplorerLink

    init(model: TransferDataViewModel, addressName: AddressName?, addressLink: BlockExplorerLink) {
        self.model = model
        self.addressName = addressName
        self.addressLink = addressLink
    }
}

// MARK: - ItemModelProvidable

extension ConfirmRecipientViewModel: ItemModelProvidable {
    var itemModel: ConfirmTransferItemModel  {
        guard showRecipient else { return .empty }
        return .recipient(
            AddressListItemViewModel(
                title: recipientTitle,
                account: SimpleAccount(
                    name: addressName?.name ?? model.recipient.name,
                    chain: model.chain,
                    address: model.recipient.address,
                    assetImage: .none
                ),
                mode: .nameOrAddress,
                addressLink: addressLink
            )
        )
    }
}

// MARK: - Private

extension ConfirmRecipientViewModel {
    private var recipientTitle: String {
        switch model.type {
        case .swap: Localized.Common.provider
        case .stake(_, let stakeType):
            switch stakeType {
            case .stake, .unstake, .redelegate, .rewards, .withdraw: Localized.Stake.validator
            case .freeze: Localized.Stake.resource
            }
        case .transfer, .deposit, .withdrawal, .transferNft, .tokenApprove, .generic, .account, .perpetual: Localized.Transfer.to
        }
    }

    private var showRecipient: Bool {
        guard !model.recipient.address.isEmpty else { return false }

        return switch model.type {
        case .stake(_, let stakeType):
            switch stakeType {
            case .stake, .unstake, .redelegate, .withdraw: true
            case .rewards: false
            case .freeze: true
            }
        case .account,
                .swap,
                .perpetual: false
        case .transfer,
                .transferNft,
                .deposit,
                .withdrawal,
                .generic,
                .tokenApprove: true
        }
    }
}
