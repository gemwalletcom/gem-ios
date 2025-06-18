// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Blockchain
import TransactionService
import Signer
import WalletsService

public protocol TransferExecutable: Sendable {
    func execute(input: TransferConfirmationInput) async throws
}

struct TransferExecutor: TransferExecutable {
    private let signer: any TransactionSigneable
    private let chainService: any ChainServiceable
    private let walletsService: WalletsService

    init(
        signer: any TransactionSigneable,
        chainService: any ChainServiceable,
        walletsService: WalletsService
    ) {
        self.signer = signer
        self.chainService = chainService
        self.walletsService = walletsService
    }

    func execute(input: TransferConfirmationInput) async throws  {
        let signedData = try sign(input: input)
        let options = broadcastOptions(data: input.data)

        for (index, transactionData) in signedData.enumerated() {
            NSLog("TransferExecutor data \(transactionData)")
            switch input.data.type.outputType {
            case .signature:
                input.delegate?(.success(transactionData))
            case .encodedTransaction:
                let hash = try await chainService.broadcast(
                    data: transactionData,
                    options: options
                )
                NSLog("TransferExecutor broadcast response hash \(hash)")

                input.delegate?(.success(hash))

                let transaction = try TransactionFactory.makePendingTransaction(
                    wallet: input.wallet,
                    transferData: input.data,
                    transactionData: input.transactionData,
                    amount: input.amount,
                    hash: hash,
                    transactionIndex: index
                )

                try walletsService.addTransactions(walletId: input.wallet.id, transactions: [transaction])
                Task {
                    try walletsService.enableBalances(
                        for: input.wallet.walletId,
                        assetIds: transaction.assetIds
                    )
                }

                if signedData.count > 1, transactionData != signedData.last {
                    try await Task.sleep(for: transactionDelay(for: input.data.chain.type))
                }
            }
        }
    }
}

// MARK: - Private

extension TransferExecutor {
    private func sign(input: TransferConfirmationInput) throws -> [String] {
        try signer.sign(
            transfer: input.data,
            transactionData: input.transactionData,
            amount: input.amount,
            wallet: input.wallet
        )
    }

    private func broadcastOptions(data: TransferData) -> BroadcastOptions {
        switch data.chain {
        case .solana:
            switch data.type {
            case .transfer, .transferNft, .stake, .account, .tokenApprove: .standard
            case .swap, .generic: BroadcastOptions(skipPreflight: true)
            }
        default: .standard
        }
    }

    private func transactionDelay(for type: ChainType) -> Duration {
        switch type {
        case .ethereum: .milliseconds(0)
        case .tron: .milliseconds(500)
        default: .milliseconds(500)
        }
    }
}
