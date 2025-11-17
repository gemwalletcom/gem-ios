// Copyright (c). Gem Wallet. All rights reserved.

import Blockchain
import Primitives
import ScanService
import BigInt
import Validators

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
        async let getFeeRates = getFeeRates(type: data.type, priority: priority)
        async let getTransactionMetadata = getTransactionMetadata(wallet: wallet, data: data)
        async let getTransactionScan = getTransactionScan(wallet: wallet, data: data)

        let (rates, metadata, scanResult) = try await (getFeeRates, getTransactionMetadata, getTransactionScan)

        if let scanResult = scanResult {
            try ScanTransactionValidator.validate(
                transaction: scanResult,
                asset: data.type.asset,
                memo: data.recipientData.recipient.memo
            )
        }

        return try await TransferTransactionData(
            allRates: rates.rates,
            transactionData: getTransactionLoad(
                wallet: wallet,
                data: data,
                available: available,
                rate: rates.selected,
                metadata: metadata
            ),
            scanResult: scanResult
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
        metadata: TransactionLoadMetadata
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
            metadata: metadata
        )

        return try await chainService.load(input: input)
    }
    
    private func getTransactionMetadata(wallet: Wallet, data: TransferData) async throws -> TransactionLoadMetadata {
        try await chainService.preload(
            input: TransactionPreloadInput(
                inputType: data.type,
                senderAddress: try wallet.account(for: data.chain).address,
                destinationAddress: data.recipientData.recipient.address
            )
        )
    }

    private func getTransactionScan(wallet: Wallet, data: TransferData) async throws -> ScanTransaction? {
        await scanService.getScanTransaction(
            chain: data.chain,
            input: TransactionPreloadInput(
                inputType: data.type,
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
}
