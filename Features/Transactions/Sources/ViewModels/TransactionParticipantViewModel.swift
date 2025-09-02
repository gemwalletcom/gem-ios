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
    
    private var participantType: ParticipantType? {
        switch transactionViewModel.transaction.transaction.type {
        case .transfer, .transferNFT:
            switch transactionViewModel.transaction.transaction.direction {
            case .incoming: .sender
            case .outgoing, .selfTransfer: .recipient
            }
        case .tokenApproval, .smartContractCall: 
            .contract
        case .stakeDelegate: 
            .validator
        case .swap,
             .stakeUndelegate,
             .stakeRedelegate,
             .stakeRewards,
             .stakeWithdraw,
             .assetActivation,
             .perpetualOpenPosition,
             .perpetualClosePosition:
            nil
        }
    }
    
    private var title: String {
        switch participantType {
        case .sender: Localized.Transaction.sender
        case .recipient: Localized.Transaction.recipient
        case .validator: Localized.Stake.validator
        case .contract: Localized.Asset.contract
        case .none: ""
        }
    }
    
    public var hasParticipant: Bool {
        participantType != nil && !transactionViewModel.participant.isEmpty
    }
    
    public var itemModel: TransactionParticipantItemModel? {
        guard hasParticipant else {
            return nil
        }
        
        let address = transactionViewModel.participant
        let chain = transactionViewModel.transaction.transaction.assetId.chain
        let name = transactionViewModel.getAddressName(address: address)
        
        let account = SimpleAccount(
            name: name,
            chain: chain,
            address: address,
            assetImage: nil
        )
        
        let addressLink = transactionViewModel.addressLink(account: account)
        
        return TransactionParticipantItemModel(
            title: title,
            account: account,
            addressLink: addressLink
        )
    }
}

public enum ParticipantType {
    case sender
    case recipient
    case validator
    case contract
}
