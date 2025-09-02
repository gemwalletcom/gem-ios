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
    
    public var itemModel: TransactionParticipantItemModel? {
        guard transactionViewModel.participant.isNotEmpty else { return nil }
        
        let transaction = transactionViewModel.transaction.transaction

        let title: String? = switch transaction.type {
        case .transfer, .transferNFT:
            switch transaction.direction {
            case .incoming: Localized.Transaction.sender
            case .outgoing, .selfTransfer: Localized.Transaction.recipient
            }
        case .tokenApproval, .smartContractCall:
            Localized.Asset.contract
        case .stakeDelegate:
            Localized.Stake.validator
        case .swap, .stakeUndelegate, .stakeRedelegate, .stakeRewards,
             .stakeWithdraw, .assetActivation, .perpetualOpenPosition, .perpetualClosePosition:
            nil
        }
        
        guard let title else { return nil }
        
        let address = transactionViewModel.participant
        let chain = transaction.assetId.chain
        
        let account = SimpleAccount(
            name: transactionViewModel.getAddressName(address: address),
            chain: chain,
            address: address,
            assetImage: nil
        )
        
        return TransactionParticipantItemModel(
            title: title,
            account: account,
            addressLink: transactionViewModel.addressLink(account: account)
        )
    }
}
