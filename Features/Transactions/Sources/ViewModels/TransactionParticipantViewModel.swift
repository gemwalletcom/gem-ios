// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization

public struct TransactionParticipantViewModel: Sendable {
    private let transactionViewModel: TransactionViewModel

    public init(transactionViewModel: TransactionViewModel) {
        self.transactionViewModel = transactionViewModel
    }

    public var itemModel: TransactionItemModel {
        guard transactionViewModel.participant.isNotEmpty,
              let participantTitle
        else {
            return .empty
        }

        let address = transactionViewModel.participant
        let chain = transactionViewModel.transaction.transaction.assetId.chain
        let account = SimpleAccount(
            name: transactionViewModel.getAddressName(address: address),
            chain: chain,
            address: address,
            assetImage: nil
        )

        return .participant(TransactionParticipantItemModel(
            title: participantTitle,
            account: account,
            addressLink: transactionViewModel.addressLink(account: account)
        ))
    }
}

// MARK: - Private

extension TransactionParticipantViewModel {
    private var participantTitle: String? {
        switch  transactionViewModel.transaction.transaction.type {
        case .transfer, .transferNFT:
            switch transactionViewModel.transaction.transaction.direction {
            case .incoming: Localized.Transaction.sender
            case .outgoing, .selfTransfer: Localized.Transaction.recipient
            }
        case .tokenApproval, .smartContractCall:
            Localized.Asset.contract
        case .stakeDelegate:
            Localized.Stake.validator
        case .swap, .stakeUndelegate, .stakeRedelegate, .stakeRewards,
                .stakeWithdraw, .assetActivation, .perpetualOpenPosition, .perpetualClosePosition: nil
        }
    }
}
