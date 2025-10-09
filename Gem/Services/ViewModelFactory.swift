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
import BalanceService
import PriceService
import TransactionService
import Staking
import Assets
import FiatConnect
import WalletConnectorService
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
    let balanceService: BalanceService
    let priceService: PriceService
    let transactionService: TransactionService
    let chainServiceFactory: ChainServiceFactory
    let addressNameService: AddressNameService
    
    public init(
        keystore: any Keystore,
        nodeService: NodeService,
        scanService: ScanService,
        swapService: SwapService,
        walletsService: WalletsService,
        walletService: WalletService,
        stakeService: StakeService,
        nameService: NameService,
        balanceService: BalanceService,
        priceService: PriceService,
        transactionService: TransactionService,
        chainServiceFactory: ChainServiceFactory,
        addressNameService: AddressNameService
    ) {
        self.keystore = keystore
        self.nodeService = nodeService
        self.scanService = scanService
        self.swapService = swapService
        self.walletsService = walletsService
        self.walletService = walletService
        self.stakeService = stakeService
        self.nameService = nameService
        self.balanceService = balanceService
        self.priceService = priceService
        self.transactionService = transactionService
        self.chainServiceFactory = chainServiceFactory
        self.addressNameService = addressNameService
    }
    
    @MainActor
    public func confirmTransferScene(
        wallet: Wallet,
        data: TransferData,
        confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate? = nil,
        onComplete: VoidAction
    ) -> ConfirmTransferSceneViewModel {
        let confirmService = ConfirmServiceFactory.create(
            keystore: keystore,
            nodeService: nodeService,
            walletsService: walletsService,
            scanService: scanService,
            balanceService: balanceService,
            priceService: priceService,
            transactionService: transactionService,
            addressNameService: addressNameService,
            chain: data.chain
        )
        
        return ConfirmTransferSceneViewModel(
            wallet: wallet,
            data: data,
            confirmService: confirmService,
            confirmTransferDelegate: confirmTransferDelegate,
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
            walletService: walletService,
            nameService: nameService,
            type: type,
            onRecipientDataAction: onRecipientDataAction,
            onTransferAction: onTransferAction
        )
    }
    
    @MainActor
    public func amountScene(
        input: AmountInput,
        wallet: Wallet,
        onTransferAction: TransferDataAction
    ) -> AmountSceneViewModel {
        return AmountSceneViewModel(
            input: input,
            wallet: wallet,
            onTransferAction: onTransferAction
        )
    }
    
    @MainActor
    public func fiatScene(
        assetAddress: AssetAddress,
        walletId: WalletId,
        type: FiatQuoteType = .buy
    ) -> FiatSceneViewModel {
        FiatSceneViewModel(
            assetAddress: assetAddress,
            walletId: walletId.id,
            type: type
        )
    }
    
    @MainActor
    public func swapScene(
        input: SwapInput,
        onSwap: @escaping (TransferData) -> Void
    ) -> SwapSceneViewModel {
        SwapSceneViewModel(
            input: input,
            walletsService: walletsService,
            swapQuotesProvider: SwapQuotesProvider(swapService: swapService),
            swapQuoteDataProvider: SwapQuoteDataProvider(keystore: keystore, swapService: swapService),
            onSwap: onSwap
        )
    }

    @MainActor
    public func stakeScene(
        wallet: Wallet,
        chain: Chain
    ) -> StakeSceneViewModel {
        StakeSceneViewModel(
            wallet: wallet,
            chain: StakeChain(rawValue: chain.rawValue)!, // Expected Only StakeChain accepted.
            stakeService: stakeService
        )
    }

    @MainActor
    public func signMessageScene(
        payload: SignMessagePayload,
        confirmTransferDelegate: @escaping TransferDataCallback.ConfirmTransferDelegate
    ) -> SignMessageSceneViewModel {
        SignMessageSceneViewModel(
            keystore: keystore,
            payload: payload,
            confirmTransferDelegate: confirmTransferDelegate
        )
    }
    
    @MainActor
    public func stakeDetailScene(
        wallet: Wallet,
        delegation: Delegation,
        onAmountInputAction: AmountInputAction,
        onTransferAction: TransferDataAction
    ) -> StakeDetailSceneViewModel {
        StakeDetailSceneViewModel(
            wallet: wallet,
            model: StakeDelegationViewModel(delegation: delegation, formatter: .auto),
            service: stakeService,
            onAmountInputAction: onAmountInputAction,
            onTransferAction: onTransferAction
        )
    }
    
}
