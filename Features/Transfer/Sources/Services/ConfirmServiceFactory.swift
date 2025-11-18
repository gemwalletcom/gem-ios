// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
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
import AddressNameService

public struct ConfirmServiceFactory {
    public static func create(
        keystore: any Keystore,
        nodeService: NodeService,
        walletsService: WalletsService,
        scanService: ScanService,
        balanceService: BalanceService,
        priceService: PriceService,
        transactionService: TransactionService,
        addressNameService: AddressNameService,
        transferStateService: TransferStateService,
        chain: Chain
    ) -> ConfirmService {
        let chainService = ChainServiceFactory(nodeProvider: nodeService).service(for: chain)

        return ConfirmService(
            explorerService: ExplorerService.standard,
            metadataProvider: TransferMetadataProvider(
                balanceService: balanceService,
                priceService: priceService
            ),
            transferTransactionProvider: TransferTransactionProvider(
                chainService: chainService,
                scanService: scanService
            ),
            transferExecutor: TransferExecutor(
                signer: TransactionSigner(keystore: keystore),
                chainService: chainService,
                walletsService: walletsService,
                transactionService: transactionService,
                transferStateService: transferStateService
            ),
            keystore: keystore,
            chainService: chainService,
            addressNameService: addressNameService
        )
    }
}
