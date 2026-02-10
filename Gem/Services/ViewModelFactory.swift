// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Transfer
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
import TransactionStateService
import Earn
import Assets
import FiatConnect
import WalletConnectorService
import AddressNameService
import ActivityService
import EventPresenterService
import EarnService
import GemAPI

public struct ViewModelFactory: Sendable {
    let keystore: any Keystore
    let nodeService: NodeService
    let scanService: ScanService
    let swapService: SwapService
    let walletsService: WalletsService
    let walletService: WalletService
    let stakeService: StakeService
    let earnProviderService: EarnProviderService
    let earnBalanceService: any EarnBalanceServiceable
    let nameService: NameService
    let balanceService: BalanceService
    let priceService: PriceService
    let transactionStateService: TransactionStateService
    let addressNameService: AddressNameService
    let activityService: ActivityService
    let eventPresenterService: EventPresenterService
    let fiatService: any GemAPIFiatService

    public init(
        keystore: any Keystore,
        nodeService: NodeService,
        scanService: ScanService,
        swapService: SwapService,
        walletsService: WalletsService,
        walletService: WalletService,
        stakeService: StakeService,
        earnProviderService: EarnProviderService,
        earnBalanceService: any EarnBalanceServiceable,
        nameService: NameService,
        balanceService: BalanceService,
        priceService: PriceService,
        transactionStateService: TransactionStateService,
        addressNameService: AddressNameService,
        activityService: ActivityService,
        eventPresenterService: EventPresenterService,
        fiatService: any GemAPIFiatService
    ) {
        self.keystore = keystore
        self.nodeService = nodeService
        self.scanService = scanService
        self.swapService = swapService
        self.walletsService = walletsService
        self.walletService = walletService
        self.stakeService = stakeService
        self.earnProviderService = earnProviderService
        self.earnBalanceService = earnBalanceService
        self.nameService = nameService
        self.balanceService = balanceService
        self.priceService = priceService
        self.transactionStateService = transactionStateService
        self.addressNameService = addressNameService
        self.activityService = activityService
        self.eventPresenterService = eventPresenterService
        self.fiatService = fiatService
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
            transactionStateService: transactionStateService,
            addressNameService: addressNameService,
            activityService: activityService,
            eventPresenterService: eventPresenterService,
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
        type: FiatQuoteType = .buy,
        amount: Int? = nil
    ) -> FiatSceneViewModel {
        FiatSceneViewModel(
            fiatService: fiatService,
            assetAddress: assetAddress,
            walletId: walletId,
            type: type,
            amount: amount
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
    public func earnScene(
        wallet: Wallet,
        chain: Chain
    ) -> EarnSceneViewModel {
        EarnSceneViewModel(
            wallet: wallet,
            chain: StakeChain(rawValue: chain.rawValue)!, // Expected Only StakeChain accepted.
            stakeService: stakeService,
            earnProviderService: earnProviderService,
            earnPositionsService: earnBalanceService,
            earnAsset: chain.asset
        )
    }

    @MainActor
    public func earnProvidersScene(
        wallet: Wallet,
        asset: Asset,
        onAmountInputAction: AmountInputAction = nil
    ) -> EarnProvidersSceneViewModel {
        EarnProvidersSceneViewModel(
            wallet: wallet,
            asset: asset,
            earnPositionsService: earnBalanceService,
            earnProviderService: earnProviderService,
            onAmountInputAction: onAmountInputAction
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
        onAmountInputAction: Earn.AmountInputAction,
        onTransferAction: Earn.TransferDataAction
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
