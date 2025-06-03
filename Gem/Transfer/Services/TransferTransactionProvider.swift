// Copyright (c). Gem Wallet. All rights reserved.

import Blockchain
import Primitives
import ScanService
import Transfer
import ScanService
import BigInt

public protocol TransferTransactionProvidable: Sendable {
    func loadTransferTransactionData(
        wallet: Wallet,
        data: TransferData,
        priority: FeePriority,
        available: BigInt
    ) async throws -> TransferTransactionData
}

public struct TransferTransactionProvider: TransferTransactionProvidable {
    private let feeRatesProvider: any FeeRateProviding
    private let chainService: any ChainServiceable
    private let scanService: ScanService

    public init(
        chainService: any ChainServiceable,
        scanService: ScanService
    ) {
        self.feeRatesProvider = FeeRateService(service: chainService)
        self.chainService = chainService
        self.scanService = scanService
    }

    public func loadTransferTransactionData(
        wallet: Wallet,
        data: TransferData,
        priority: FeePriority,
        available: BigInt
    ) async throws -> TransferTransactionData {
        async let getTransactionValidation: () = validateTransaction(wallet: wallet, data: data)
        async let getFeeRates = getFeeRates(type: data.type, priority: priority)
        async let getTransactionPreload = getTransactionPreload(wallet: wallet, data: data)

        let (rates, preload, _) = try await (getFeeRates, getTransactionPreload, getTransactionValidation)

        return try await TransferTransactionData(
            allRates: rates.rates,
            transactionData: getTransactionLoad(
                wallet: wallet,
                data: data,
                available: available,
                rate: rates.selected,
                preload: preload
            )
        )
    }
}

// MARK: - Private

extension TransferTransactionProvider {
    private func getTransactionLoad(
        wallet: Wallet,
        data: TransferData,
        available: BigInt,
        rate: FeeRate,
        preload: TransactionPreload
    ) async throws -> TransactionData {
        let input = TransactionInput(
            type: data.type,
            asset: data.type.asset,
            senderAddress: try wallet.account(for: data.chain).address,
            destinationAddress: data.recipientData.recipient.address,
            value: data.value,
            balance: available,
            gasPrice: rate.gasPriceType,
            memo: data.recipientData.recipient.memo,
            preload: preload
        )

        return try await chainService.load(input: input)
    }

    private func getTransactionPreload(wallet: Wallet, data: TransferData) async throws -> TransactionPreload {
        try await chainService.preload(
            input: TransactionPreloadInput(
                senderAddress: try wallet.account(for: data.chain).address,
                destinationAddress: data.recipientData.recipient.address
            )
        )
    }

    private func getFeeRates(type: TransferDataType, priority: FeePriority) async throws -> (rates: [FeeRate], selected: FeeRate) {
        let rates = try await feeRatesProvider.rates(for: type)
        guard let selected = rates.first(where: { $0.priority == priority }) else {
            throw ChainCoreError.feeRateMissed
        }

        return (rates, selected)
    }

    private func validateTransaction(wallet: Wallet, data: TransferData) async throws {
        let scanPayload = try scanService.getTransactionPayload(
            wallet: wallet,
            transferType: data.type,
            recipient: data.recipientData
        )
        let isValid = try await scanService.isValidTransaction(scanPayload)
        if !isValid {
            throw AnyError("Transaction is invalid")
        }
    }
}
