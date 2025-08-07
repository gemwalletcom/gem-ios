// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Transfer
import ChainService
import Keystore
import SwapService
import Swap
import WalletsService
import ScanService
import WalletConnector
import WalletService
import NodeService
import StakeService
import NameService
import AddressNameService

public struct ViewModelFactory: Sendable {
    let keystore: any Keystore
    let nodeService: NodeService
    let scanService: ScanService
    let swapService: SwapService
    let walletsService: WalletsService
    let walletService: WalletService
    let stakeService: StakeService
    let nameService: NameService
    let addressNameService: AddressNameService
    let chainServiceFactory: ChainServiceFactory
    
    public init(
        keystore: any Keystore,
        nodeService: NodeService,
        scanService: ScanService,
        swapService: SwapService,
        walletsService: WalletsService,
        walletService: WalletService,
        stakeService: StakeService,
        nameService: NameService,
        addressNameService: AddressNameService,
        chainServiceFactory: ChainServiceFactory
    ) {
        self.keystore = keystore
        self.nodeService = nodeService
        self.scanService = scanService
        self.swapService = swapService
        self.walletsService = walletsService
        self.walletService = walletService
        self.stakeService = stakeService
        self.nameService = nameService
        self.addressNameService = addressNameService
        self.chainServiceFactory = chainServiceFactory
    }
    
    @MainActor
    public func confirmTransfer(
        wallet: Wallet,
        data: TransferData,
        onComplete: VoidAction
    ) -> ConfirmTransferViewModel {
        ConfirmTransferViewModel(
            wallet: wallet,
            data: data,
            keystore: keystore,
            chainService: chainServiceFactory.service(for: data.chain),
            scanService: scanService,
            swapService: swapService,
            walletsService: walletsService,
            swapDataProvider: SwapQuoteDataProvider(
                keystore: keystore,
                swapService: swapService
            ),
            addressNameService: addressNameService,
            onComplete: onComplete
        )
    }
    
    @MainActor
    public func recipientScene(
        wallet: Wallet,
        asset: Asset,
        type: RecipientAssetType,
        onRecipientDataAction: RecipientDataAction,
        onTransferAction: TransferDataAction
    ) -> RecipientSceneViewModel {
        RecipientSceneViewModel(
            wallet: wallet,
            asset: asset,
            keystore: keystore,
            walletService: walletService,
            walletsService: walletsService,
            nodeService: nodeService,
            stakeService: stakeService,
            scanService: scanService,
            swapService: swapService,
            nameService: nameService,
            type: type,
            addressNameService: addressNameService,
            onRecipientDataAction: onRecipientDataAction,
            onTransferAction: onTransferAction
        )
    }
}
