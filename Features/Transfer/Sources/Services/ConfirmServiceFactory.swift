// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwapService
import BalanceService
import PriceService
import TransactionService
import ExplorerService
import Keystore
import WalletsService
import ScanService
import NodeService
import Primitives
import ChainService
import Signer

public struct ConfirmServiceFactory {
    public static func create(
        keystore: any Keystore,
        nodeService: NodeService,
        walletsService: WalletsService,
        scanService: ScanService,
        swapService: SwapService,
        balanceService: BalanceService,
        priceService: PriceService,
        transactionService: TransactionService,
        chain: Chain
    ) -> ConfirmService {
        let chainService = ChainServiceFactory(nodeProvider: nodeService).service(for: chain)

        return ConfirmService(
            swapDataProvider: SwapQuoteDataProvider(
                keystore: keystore,
                swapService: swapService
            ),
            explorerService: ExplorerService.standard,
            metadataProvider: TransferMetadataProvider(
                balanceService: balanceService,
                priceService: priceService
            ),
            transferTransactionProvider: TransferTransactionProvider(
                chainService: chainService,
                scanService: scanService,
                swapService: swapService
            ),
            transferExecutor: TransferExecutor(
                signer: TransactionSigner(keystore: keystore),
                chainService: chainService,
                walletsService: walletsService,
                transactionService: transactionService
            ),
            keystore: keystore,
            swapService: swapService,
            chainService: chainService
        )
    }
}
