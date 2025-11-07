// Copyright (c). Gem Wallet. All rights reserved.

import Blockchain
import Foundation
import Primitives
import Signer
import TransactionService
import WalletsService

public protocol TransferExecutable: Sendable {
    func execute(input: TransferConfirmationInput) async throws
}

public struct TransferExecutor: TransferExecutable {
    private let signer: any TransactionSigneable
    private let chainService: any ChainServiceable
    private let walletsService: WalletsService
    private let transactionService: TransactionService

    public init(
        signer: any TransactionSigneable,
        chainService: any ChainServiceable,
        walletsService: WalletsService,
        transactionService: TransactionService
    ) {
        self.signer = signer
        self.chainService = chainService
        self.walletsService = walletsService
        self.transactionService = transactionService
    }

    public func execute(input: TransferConfirmationInput) async throws {
        let signedData = try await sign(input: input)
        let options = broadcastOptions(data: input.data)

        for (index, transactionData) in signedData.enumerated() {
            debugLog("TransferExecutor data \(transactionData)")

            switch input.data.type.outputAction {
            case .sign:
                input.delegate?(.success(transactionData))
            case .send:
                let hash = try await chainService.broadcast(
                    data: transactionData,
                    options: options
                )
                debugLog("TransferExecutor broadcast response hash \(hash)")

                input.delegate?(.success(hash))

                let transaction = try TransactionFactory.makePendingTransaction(
                    wallet: input.wallet,
                    transferData: input.data,
                    transactionData: input.transactionData,
                    amount: input.amount,
                    hash: hash,
                    transactionIndex: index
                )
                let excludeChains = [Chain.hyperCore]
                let assetIds = transaction.assetIds.filter { !excludeChains.contains($0.chain) }
                let transactions = [transaction].filter { tx in
                    switch input.data.type {
                    case .perpetual: !excludeChains.contains(tx.assetId.chain) || index == signedData.count - 1
                    default: true
                    }
                }

                try transactionService.addTransactions(wallet: input.wallet, transactions: transactions)
                Task {
                    try walletsService.addBalancesIfMissing(
                        for: input.wallet.walletId,
                        assetIds: assetIds,
                        isEnabled: true
                    )
                    await walletsService.enableAssets(walletId: input.wallet.walletId, assetIds: assetIds, enabled: true)
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
    private func sign(input: TransferConfirmationInput) async throws -> [String] {
        try await signer.sign(
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
            case .transfer, .deposit, .withdrawal, .transferNft, .stake, .account, .tokenApprove, .perpetual: BroadcastOptions(
                skipPreflight: false
            )
            case .swap, .generic: BroadcastOptions(skipPreflight: true)
            }
        default: BroadcastOptions(skipPreflight: false)
        }
    }

    private func transactionDelay(for type: ChainType) -> Duration {
        switch type {
        case .ethereum, .hyperCore: .milliseconds(0)
        case .tron: .milliseconds(500)
        default: .milliseconds(500)
        }
    }
}
