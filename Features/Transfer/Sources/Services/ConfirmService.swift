// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwapService
import BalanceService
import PriceService
import TransactionService
import ExplorerService
import Keystore
import Swap
import WalletsService
import ScanService
import Primitives
import PrimitivesComponents
import BigInt
import Blockchain
import ChainService

public struct ConfirmService: Sendable {
    private let swapDataProvider: any SwapQuoteDataProvidable
    private let metadataProvider: any TransferMetadataProvidable
    private let transferTransactionProvider: any TransferTransactionProvidable
    private let transferExecutor: any TransferExecutable
    private let keystore: any Keystore
    private let swapService: SwapService
    private let chainService: any ChainServiceable

    // TODO: - should be private
    let explorerService: any ExplorerLinkFetchable

    public init(
        swapDataProvider: any SwapQuoteDataProvidable,
        explorerService: any ExplorerLinkFetchable,
        metadataProvider: any TransferMetadataProvidable,
        transferTransactionProvider: any TransferTransactionProvidable,
        transferExecutor: any TransferExecutable,
        keystore: any Keystore,
        swapService: SwapService,
        chainService: any ChainServiceable
    ) {
        self.swapDataProvider = swapDataProvider
        self.explorerService = explorerService
        self.metadataProvider = metadataProvider
        self.transferTransactionProvider = transferTransactionProvider
        self.transferExecutor = transferExecutor
        self.keystore = keystore
        self.swapService = swapService
        self.chainService = chainService
    }

    public func getMetadata(wallet: Wallet, data: TransferData) throws -> TransferDataMetadata {
        try metadataProvider.metadata(wallet: wallet, data: data)
    }

    public func getExplorerLink(chain: Chain, address: String) -> BlockExplorerLink {
        explorerService.addressUrl(chain: chain, address: address)
    }

    public func loadTransferTransactionData(
        wallet: Wallet,
        data: TransferData,
        priority: FeePriority,
        available: BigInt
    ) async throws -> TransferTransactionData {
        try await transferTransactionProvider.loadTransferTransactionData(
            wallet: wallet,
            data: data,
            priority: priority,
            available: available
        )
    }

    public func executeTransfer(input: TransferConfirmationInput) async throws {
        try await transferExecutor.execute(input: input)
    }

    public func getPasswordAuthentication() throws -> KeystoreAuthentication {
        try keystore.getPasswordAuthentication()
    }

    public func defaultPriority(for type: TransferDataType) -> FeePriority {
        chainService.defaultPriority(for: type)
    }
}
