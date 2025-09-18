// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct TransactionFactory {
    public static func makePendingTransaction(
        wallet: Wallet,
        transferData: TransferData,
        transactionData: TransactionData,
        amount: TransferAmount,
        hash: String,
        transactionIndex: Int
    ) throws -> Primitives.Transaction {

        let senderAddress = try wallet.account(for: transferData.chain).address
        let recipientAddress = transferData.recipientData.recipient.address
        let metadata = transferData.type.metadata
        let direction: TransactionDirection = senderAddress == recipientAddress ? .selfTransfer : .outgoing

        let data: (type: TransactionType, metadata: TransactionMetadata) = switch transferData.type {
        case .swap(_, _, let data):
            switch data.approval {
            case .some: transactionIndex == 0 ? (.tokenApproval, .null) : (.swap, metadata)
            case .none: (.swap, transferData.type.metadata)
            }
        default: (transferData.type.transactionType, metadata)
        }
        let state = TransactionState.pending

        return Transaction(
            id: Transaction.id(chain: transferData.chain, hash: hash),
            hash: hash,
            assetId: transferData.type.asset.id,
            from: senderAddress,
            to: recipientAddress,
            contract: nil,
            type: data.type,
            state: state,
            blockNumber: (try? String(transactionData.metadata.getBlockNumber())) ?? "0",
            sequence: (try? String(transactionData.metadata.getSequence())) ?? "0",
            fee: amount.networkFee.description,
            feeAssetId: transferData.type.asset.feeAsset.id,
            value: amount.value.description,
            memo: transferData.recipientData.recipient.memo ?? "",
            direction: direction,
            utxoInputs: [],
            utxoOutputs: [],
            metadata: data.metadata,
            createdAt: Date()
        )
    }
}
