// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BalanceService
import PriceService
import TransactionStateService
import ExplorerService
import Keystore
import WalletsService
import ScanService
import Primitives
import ChainService
import Signer
import AddressNameService
import ActivityService
import EventPresenterService

public struct ConfirmServiceFactory {
    public static func create(
        keystore: any Keystore,
        chainServiceFactory: any ChainServiceFactorable,
        assetsEnabler: any AssetsEnabler,
        scanService: ScanService,
        balanceService: BalanceService,
        priceService: PriceService,
        transactionStateService: TransactionStateService,
        addressNameService: AddressNameService,
        activityService: ActivityService,
        eventPresenterService: EventPresenterService,
        chain: Chain
    ) -> ConfirmService {
        let chainService = chainServiceFactory.service(for: chain)

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
                assetsEnabler: assetsEnabler,
                balanceService: balanceService,
                transactionStateService: transactionStateService
            ),
            keystore: keystore,
            chainService: chainService,
            addressNameService: addressNameService,
            activityService: activityService,
            eventPresenterService: eventPresenterService
        )
    }
}
